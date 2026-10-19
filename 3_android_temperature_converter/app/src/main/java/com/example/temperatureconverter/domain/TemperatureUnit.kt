package com.example.temperatureconverter.domain

enum class TemperatureUnit(
    val displayName: String,
    val symbol: String,
    /** Lowest physically possible value in this unit. */
    val absoluteZero: Double,
) {
    CELSIUS("Celsius", "°C", -273.15),
    FAHRENHEIT("Fahrenheit", "°F", -459.67),
    KELVIN("Kelvin", "K", 0.0),
}
