// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StolenTee",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "StolenTee",
            targets: ["StolenTee"]
        )
    ],
    dependencies: [
        // Supabase Swift SDK for OAuth
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
        // Stripe iOS SDK for payments
        .package(url: "https://github.com/stripe/stripe-ios-spm", from: "23.0.0")
    ],
    targets: [
        .target(
            name: "StolenTee",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "StripePaymentSheet", package: "stripe-ios-spm")
            ],
            path: "StolenTee"
        )
    ]
)