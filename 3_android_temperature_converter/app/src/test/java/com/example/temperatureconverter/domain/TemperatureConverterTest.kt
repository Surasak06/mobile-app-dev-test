package com.example.temperatureconverter.domain

import com.example.temperatureconverter.domain.TemperatureUnit.CELSIUS
import com.example.temperatureconverter.domain.TemperatureUnit.FAHRENHEIT
import com.example.temperatureconverter.domain.TemperatureUnit.KELVIN
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class TemperatureConverterTest {

    private fun formatted(input: String, from: TemperatureUnit, to: TemperatureUnit): String {
        val result = TemperatureConverter.convertInput(input, from, to)
        assertTrue("Expected Success for '$input' but was $result", result is ConversionResult.Success)
        return (result as ConversionResult.Success).formatted
    }

    // Examples table from the brief
    @Test fun `0 C to F is 32_00`() = assertEquals("32.00", formatted("0", CELSIUS, FAHRENHEIT))
    @Test fun `100 C to K is 373_15`() = assertEquals("373.15", formatted("100", CELSIUS, KELVIN))
    @Test fun `32 F to C is 0_00`() = assertEquals("0.00", formatted("32", FAHRENHEIT, CELSIUS))
    @Test fun `273_15 K to C is 0_00`() = assertEquals("0.00", formatted("273.15", KELVIN, CELSIUS))
    @Test fun `minus 40 C to F is minus 40_00`() = assertEquals("-40.00", formatted("-40", CELSIUS, FAHRENHEIT))

    // Acceptance criteria
    @Test fun `100 C to F is 212_00`() = assertEquals("212.00", formatted("100", CELSIUS, FAHRENHEIT))
    @Test fun `0 K to C is minus 273_15`() = assertEquals("-273.15", formatted("0", KELVIN, CELSIUS))

    @Test fun `F to K goes through Celsius`() {
        assertEquals("273.15", formatted("32", FAHRENHEIT, KELVIN))
        assertEquals("212.00", formatted("373.15", KELVIN, FAHRENHEIT))
        assertEquals("0.00", formatted("-459.67", FAHRENHEIT, KELVIN))
    }

    @Test fun `same unit returns original value`() {
        assertEquals("36.60", formatted("36.6", CELSIUS, CELSIUS))
        assertEquals("-12.35", formatted("-12.345", FAHRENHEIT, FAHRENHEIT))
    }

    @Test fun `decimal and negative inputs are supported`() {
        assertEquals("97.88", formatted("36.6", CELSIUS, FAHRENHEIT))
        assertEquals("-17.78", formatted("0", FAHRENHEIT, CELSIUS))
        assertEquals("0.50", formatted(".5", CELSIUS, CELSIUS))
        assertEquals("98.60", formatted("37,0", CELSIUS, FAHRENHEIT))
    }

    @Test fun `below absolute zero is rejected for every unit`() {
        assertEquals(ConversionResult.BelowAbsoluteZero(CELSIUS), TemperatureConverter.convertInput("-274", CELSIUS, FAHRENHEIT))
        assertEquals(ConversionResult.BelowAbsoluteZero(CELSIUS), TemperatureConverter.convertInput("-273.16", CELSIUS, KELVIN))
        assertEquals(ConversionResult.BelowAbsoluteZero(FAHRENHEIT), TemperatureConverter.convertInput("-459.68", FAHRENHEIT, CELSIUS))
        assertEquals(ConversionResult.BelowAbsoluteZero(KELVIN), TemperatureConverter.convertInput("-0.01", KELVIN, CELSIUS))
    }

    @Test fun `exactly absolute zero is allowed`() {
        assertEquals("0.00", formatted("-273.15", CELSIUS, KELVIN))
        assertEquals("-273.15", formatted("-459.67", FAHRENHEIT, CELSIUS))
        assertEquals("-459.67", formatted("0", KELVIN, FAHRENHEIT))
    }

    @Test fun `blank input returns Empty`() {
        assertEquals(ConversionResult.Empty, TemperatureConverter.convertInput("", CELSIUS, FAHRENHEIT))
        assertEquals(ConversionResult.Empty, TemperatureConverter.convertInput("   ", CELSIUS, FAHRENHEIT))
    }

    @Test fun `invalid input returns InvalidNumber without crashing`() {
        listOf("abc", "-", ".", "-.", "12a", "1.2.3", "--5", "NaN", "Infinity", "1e5", "0x10").forEach { input ->
            assertEquals(
                "input='$input'",
                ConversionResult.InvalidNumber,
                TemperatureConverter.convertInput(input, CELSIUS, FAHRENHEIT),
            )
        }
    }

    @Test fun `swapping units converts back`() {
        val toF = formatted("25", CELSIUS, FAHRENHEIT)
        assertEquals("77.00", toF)
        assertEquals("25.00", formatted(toF, FAHRENHEIT, CELSIUS))
    }
}
