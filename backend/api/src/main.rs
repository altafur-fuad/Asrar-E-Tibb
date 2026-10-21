mod config;
mod error;
mod models;
mod routes;

use axum::http::{header, Method};
use std::{net::SocketAddr, sync::Arc, time::Duration};
use tower_http::{
    cors::{Any, CorsLayer},
    timeout::TimeoutLayer,
    trace::TraceLayer,
};
use tracing::{info, warn};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

use crate::config::AppConfig;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize structured logging
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "asrar_e_tibb_api=info,tower_http=info".into()),
        )
        .with(tracing_subscriber::fmt::layer().json())
        .init();

    info!("Starting Asrar-e-Tibb Healthcare API service...");

    // Load configuration from environment
    let config = Arc::new(AppConfig::from_env());
    let addr = SocketAddr::from(([0, 0, 0, 0], config.port));

    // Configure CORS
    let cors = if config.allowed_origins.contains(&"*".to_string()) {
        CorsLayer::new()
            .allow_origin(Any)
            .allow_methods([Method::GET, Method::POST, Method::OPTIONS])
            .allow_headers([header::CONTENT_TYPE, header::AUTHORIZATION, header::ACCEPT])
    } else {
        let mut origins = Vec::new();
        for origin in &config.allowed_origins {
            if let Ok(val) = origin.parse() {
                origins.push(val);
            }
        }
        CorsLayer::new()
            .allow_origin(origins)
            .allow_methods([Method::GET, Method::POST, Method::OPTIONS])
            .allow_headers([header::CONTENT_TYPE, header::AUTHORIZATION, header::ACCEPT])
    };

    // Build Axum router
    let app = routes::create_router(config.clone())
        .layer(TraceLayer::new_for_http())
        .layer(cors)
        .layer(TimeoutLayer::new(Duration::from_secs(30)));

    info!(
        port = config.port,
        apk_version = %config.apk_version,
        "Binding HTTP listener to {}", addr
    );

    let listener = tokio::net::TcpListener::bind(addr).await?;

    axum::serve(listener, app)
        .with_graceful_shutdown(shutdown_signal())
        .await?;

    info!("Asrar-e-Tibb API has gracefully terminated.");
    Ok(())
}

async fn shutdown_signal() {
    let ctrl_c = async {
        tokio::signal::ctrl_c()
            .await
            .expect("failed to install Ctrl+C handler");
    };

    #[cfg(unix)]
    let terminate = async {
        tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate())
            .expect("failed to install signal handler")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {
            warn!("Shutdown signal received (Ctrl+C). Terminating gracefully...");
        },
        _ = terminate => {
            warn!("Termination signal received (SIGTERM). Terminating gracefully...");
        },
    }
}
