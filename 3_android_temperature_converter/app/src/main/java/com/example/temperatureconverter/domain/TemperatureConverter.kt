package com.example.temperatureconverter.domain

import java.math.BigDecimal
import java.math.RoundingMode

/** Result of converting raw user input. Never throws. */
sealed interface ConversionResult {
    /** Input is blank; nothing to convert yet. */
    data object Empty : ConversionResult

    /** Input is not a finite number (letters, "-", ".", "1e", ...). */
    data object InvalidNumber : ConversionResult

    /** Input is below absolute zero for [unit]. */
    data class BelowAbsoluteZero(val unit: TemperatureUnit) : ConversionResult

    data class Success(val value: Double, val unit: TemperatureUnit) : ConversionResult {
        /** Always two decimals, e.g. "212.00". Never "-0.00". */
        val formatted: String get() = TemperatureConverter.format(value)
    }
}

/** Pure conversion logic, kept free of Android dependencies so it is unit-testable. */
object TemperatureConverter {

    fun convert(value: Double, from: TemperatureUnit, to: TemperatureUnit): Double {
        if (from == to) return value
        return fromCelsius(toCelsius(value, from), to)
    }

    /** Parses, validates and converts. Accepts "," as decimal separator. */
    fun convertInput(input: String, from: TemperatureUnit, to: TemperatureUnit): ConversionResult {
        val trimmed = input.trim()
        if (trimmed.isEmpty()) return ConversionResult.Empty

        val value = parse(trimmed) ?: return ConversionResult.InvalidNumber
        if (value < from.absoluteZero) return ConversionResult.BelowAbsoluteZero(from)

        return ConversionResult.Success(convert(value, from, to), to)
    }

    fun format(value: Double): String =
        BigDecimal.valueOf(value).setScale(2, RoundingMode.HALF_UP).toPlainString()

    private val numberPattern = Regex("""^[+-]?(\d+\.?\d*|\.\d+)$""")

    private fun parse(text: String): Double? {
        val normalized = text.replace(',', '.')
        if (!numberPattern.matches(normalized)) return null
        return normalized.toDoubleOrNull()?.takeIf { it.isFinite() }
    }

    private fun toCelsius(value: Double, from: TemperatureUnit): Double = when (from) {
        TemperatureUnit.CELSIUS -> value
        TemperatureUnit.FAHRENHEIT -> (value - 32.0) * 5.0 / 9.0
        TemperatureUnit.KELVIN -> value - 273.15
    }

    private fun fromCelsius(celsius: Double, to: TemperatureUnit): Double = when (to) {
        TemperatureUnit.CELSIUS -> celsius
        TemperatureUnit.FAHRENHEIT -> celsius * 9.0 / 5.0 + 32.0
        TemperatureUnit.KELVIN -> celsius + 273.15
    }
}
