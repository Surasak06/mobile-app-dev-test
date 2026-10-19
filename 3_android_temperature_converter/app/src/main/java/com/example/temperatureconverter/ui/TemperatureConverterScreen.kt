package com.example.temperatureconverter.ui

import androidx.compose.animation.AnimatedContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.SwapVert
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalIconButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.temperatureconverter.R
import com.example.temperatureconverter.domain.ConversionResult
import com.example.temperatureconverter.domain.TemperatureConverter
import com.example.temperatureconverter.domain.TemperatureUnit
import com.example.temperatureconverter.ui.theme.TemperatureConverterTheme

/**
 * Stateful entry point. State is saved with rememberSaveable so the input and
 * selected units survive rotation and are never reset when a unit changes.
 */
@Composable
fun TemperatureConverterScreen() {
    var input by rememberSaveable { mutableStateOf("") }
    var from by rememberSaveable { mutableStateOf(TemperatureUnit.CELSIUS) }
    var to by rememberSaveable { mutableStateOf(TemperatureUnit.FAHRENHEIT) }

    // Recomputed instantly whenever the input or either unit changes.
    val result = remember(input, from, to) { TemperatureConverter.convertInput(input, from, to) }

    TemperatureConverterContent(
        input = input,
        from = from,
        to = to,
        result = result,
        onInputChange = { input = it },
        onFromChange = { from = it },
        onToChange = { to = it },
        onSwap = {
            val previousFrom = from
            from = to
            to = previousFrom
        },
        onToggleSign = { input = toggleSign(input) },
        onClear = { input = "" },
    )
}

internal fun toggleSign(text: String): String =
    if (text.startsWith("-")) text.removePrefix("-") else "-$text"

/** Stateless UI, easy to preview and test. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TemperatureConverterContent(
    input: String,
    from: TemperatureUnit,
    to: TemperatureUnit,
    result: ConversionResult,
    onInputChange: (String) -> Unit,
    onFromChange: (TemperatureUnit) -> Unit,
    onToChange: (TemperatureUnit) -> Unit,
    onSwap: () -> Unit,
    onToggleSign: () -> Unit,
    onClear: () -> Unit,
) {
    Scaffold(
        topBar = { TopAppBar(title = { Text(stringResource(R.string.app_name)) }) },
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .imePadding()
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            TemperatureInput(
                input = input,
                unit = from,
                result = result,
                onInputChange = onInputChange,
                onToggleSign = onToggleSign,
                onClear = onClear,
            )

            UnitSelector(
                label = stringResource(R.string.from_label),
                selected = from,
                onSelected = onFromChange,
            )

            val swapDescription = stringResource(R.string.swap_units)
            FilledTonalIconButton(
                onClick = onSwap,
                modifier = Modifier
                    .align(Alignment.CenterHorizontally)
                    .semantics { contentDescription = swapDescription },
            ) {
                Icon(Icons.Filled.SwapVert, contentDescription = null)
            }

            UnitSelector(
                label = stringResource(R.string.to_label),
                selected = to,
                onSelected = onToChange,
            )

            ResultCard(result = result)
        }
    }
}

@Composable
private fun TemperatureInput(
    input: String,
    unit: TemperatureUnit,
    result: ConversionResult,
    onInputChange: (String) -> Unit,
    onToggleSign: () -> Unit,
    onClear: () -> Unit,
) {
    val errorMessage = when (result) {
        ConversionResult.InvalidNumber -> stringResource(R.string.error_invalid_number)
        is ConversionResult.BelowAbsoluteZero -> stringResource(
            R.string.error_below_absolute_zero,
            "${TemperatureConverter.format(result.unit.absoluteZero)} ${result.unit.symbol}",
        )
        else -> null
    }
    val supporting = errorMessage
        ?: if (result == ConversionResult.Empty) stringResource(R.string.hint_empty) else null

    OutlinedTextField(
        value = input,
        onValueChange = onInputChange,
        modifier = Modifier.fillMaxWidth(),
        label = { Text(stringResource(R.string.input_label)) },
        placeholder = { Text(stringResource(R.string.input_placeholder)) },
        suffix = { Text(unit.symbol) },
        singleLine = true,
        isError = errorMessage != null,
        supportingText = if (supporting != null) {
            { Text(supporting) }
        } else {
            null
        },
        keyboardOptions = KeyboardOptions(
            keyboardType = KeyboardType.Decimal,
            imeAction = ImeAction.Done,
        ),
        leadingIcon = {
            // Some keyboards hide "-" on the decimal pad, so offer a sign toggle.
            val description = stringResource(R.string.toggle_sign)
            IconButton(
                onClick = onToggleSign,
                modifier = Modifier.semantics { contentDescription = description },
            ) {
                Text("±", style = MaterialTheme.typography.titleLarge)
            }
        },
        trailingIcon = if (input.isNotEmpty()) {
            {
                IconButton(onClick = onClear) {
                    Icon(Icons.Filled.Clear, contentDescription = stringResource(R.string.clear_input))
                }
            }
        } else {
            null
        },
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun UnitSelector(
    label: String,
    selected: TemperatureUnit,
    onSelected: (TemperatureUnit) -> Unit,
) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(label, style = MaterialTheme.typography.labelLarge)
        val units = TemperatureUnit.entries
        SingleChoiceSegmentedButtonRow(modifier = Modifier.fillMaxWidth()) {
            units.forEachIndexed { index, unit ->
                SegmentedButton(
                    selected = unit == selected,
                    onClick = { onSelected(unit) },
                    shape = SegmentedButtonDefaults.itemShape(index = index, count = units.size),
                    label = {
                        Text(
                            text = unit.symbol,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    },
                    modifier = Modifier.semantics { contentDescription = "$label ${unit.displayName}" },
                )
            }
        }
    }
}

@Composable
private fun ResultCard(result: ConversionResult) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer,
            contentColor = MaterialTheme.colorScheme.onPrimaryContainer,
        ),
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Text(stringResource(R.string.result_label), style = MaterialTheme.typography.labelLarge)
            Spacer(Modifier.height(8.dp))
            val text = when (result) {
                is ConversionResult.Success -> "${result.formatted} ${result.unit.symbol}"
                else -> stringResource(R.string.result_placeholder)
            }
            AnimatedContent(targetState = text, label = "result") { value ->
                Text(
                    text = value,
                    style = MaterialTheme.typography.displaySmall,
                    fontWeight = FontWeight.SemiBold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun PreviewSuccess() {
    TemperatureConverterTheme(dynamicColor = false) {
        TemperatureConverterContent(
            input = "100",
            from = TemperatureUnit.CELSIUS,
            to = TemperatureUnit.FAHRENHEIT,
            result = TemperatureConverter.convertInput("100", TemperatureUnit.CELSIUS, TemperatureUnit.FAHRENHEIT),
            onInputChange = {}, onFromChange = {}, onToChange = {}, onSwap = {}, onToggleSign = {}, onClear = {},
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun PreviewError() {
    TemperatureConverterTheme(dynamicColor = false) {
        TemperatureConverterContent(
            input = "-274",
            from = TemperatureUnit.CELSIUS,
            to = TemperatureUnit.FAHRENHEIT,
            result = TemperatureConverter.convertInput("-274", TemperatureUnit.CELSIUS, TemperatureUnit.FAHRENHEIT),
            onInputChange = {}, onFromChange = {}, onToChange = {}, onSwap = {}, onToggleSign = {}, onClear = {},
        )
    }
}
