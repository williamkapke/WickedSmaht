// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Â© MarketKap

// Changelog:
// vhawkx - added customizable colors and lines 2023-03-25
// MarketKap - added SMAs 2023-04-06
// vhawkx - added other MA options 2023-04-14

//@version=5

indicator("WST DB 5-on-1", overlay = true, max_boxes_count = 156, max_lines_count = 195)

var down5MinColor = input.color(#DE5E5788, title = "5m Candle Down Color")
var up5MinColor = input.color(#52A49A88, title = "5m Candle Up Color")
var doubleTopBottomLineColor = input.color(color.new(color.white, 30), title = "Color", group = "Double Top/Bottom Line")
var doubleTopBottomLineWidth = input.int(3, minval = 1, maxval = 5, title = "Width", group = "Double Top/Bottom Line")
var doubleTopBottomLineOption = input.string("Solid", options = ["Solid", "Dotted"], title = "Style", group = "Double Top/Bottom Line")
var doubleTopBottomLineStyle = (doubleTopBottomLineOption == "Solid") ? line.style_solid : (doubleTopBottomLineOption == "Dotted") ? line.style_dotted : na
var doubleTopBottomCloseColor = input.color(color.new(color.yellow, 30), title = "Color", group = "Double Top/Bottom Close Line")
var doubleTopBottomCloseLineWidth = input.int(2, minval = 1, maxval = 5, title = "Width", group = "Double Top/Bottom Close Line")
var doubleTopBottomCloseLineOption = input.string("Solid", options = ["Solid", "Dotted"], title = "Style", group = "Double Top/Bottom Close Line")
var doubleTopBottomCloseLineStyle = (doubleTopBottomCloseLineOption == "Solid") ? line.style_solid : (doubleTopBottomCloseLineOption == "Dotted") ? line.style_dotted : na

var sessionBarCount = 0
if ta.change(session.ismarket)
    sessionBarCount := 0

getColor(i) =>
    close[i] >= open[i] ? 'green' : 'red'

isOppositeColor() =>
    last5min = close[5] >= open[9] ? 'green' : 'red'
    this5min = close >= open[4] ? 'green' : 'red'
    last5min != this5min

var box candle5Min = na
var line doubleBottomLine = na
var isNew5MinCandle = false
var wasDoubleBarrel = false
var isOneMin = timeframe.period == '1'

sessionBarCount += 1
currentCandleWithin5MinBar = (minute) % 5
if ta.change(currentCandleWithin5MinBar) and currentCandleWithin5MinBar == 0
    isNew5MinCandle := true
    opening5MinBar = bar_index

bgcolor = open[currentCandleWithin5MinBar] >= close ? down5MinColor : up5MinColor

if isOneMin and session.ismarket //and sessionBarCount < 100
    last5min = close[currentCandleWithin5MinBar + 1] >= open[currentCandleWithin5MinBar + 5] ? 'green' : 'red'
    this5min = close >= open[currentCandleWithin5MinBar] ? 'green' : 'red'

    if isNew5MinCandle
        isNew5MinCandle := false
        candle5Min := box.new(bar_index, open, bar_index + 4, close, border_width = 0)
        two5minBarsBack = close[currentCandleWithin5MinBar + 6] >= open[currentCandleWithin5MinBar + 10] ? 'green' : 'red'

        wasDoubleBarrel := two5minBarsBack != last5min and not session.isfirstbar
        if not wasDoubleBarrel // 2 same color bars are not a double bottom
            line.delete(doubleBottomLine)
        else
            sizeOfLast5MinBar = open[5] - close[1]
            stop = open + (sizeOfLast5MinBar * .5)
            up = last5min == 'green'
            line.new(bar_index[3], close[1], bar_index + 4, close[1], style = doubleTopBottomCloseLineStyle, color = doubleTopBottomCloseColor, width = doubleTopBottomCloseLineWidth)

        offset = last5min == 'green' ? .01 : -.01
        y = math.max(open, close[1]) + offset
        doubleBottomLine := line.new(bar_index[5], y, bar_index + 4, y, style = doubleTopBottomLineStyle, width = doubleTopBottomLineWidth, color = doubleTopBottomLineColor)
    else
        wasDoubleBarrel := false

    candle5Min.set_rightbottom(bar_index + (4 - currentCandleWithin5MinBar), close)
    candle5Min.set_bgcolor(bgcolor)

FirstMATF = input.timeframe("5", title = "MA1 Timeframe", group = "Moving Average 1")
FirstMASource = input(close, title = "MA1 Source", group = "Moving Average 1")
FirstMALength = input.int(9, title = "MA1 Length", group = "Moving Average 1")
string FirstMAType = input.string(defval = "SMA", options = ["SMA", "EMA", "WMA", "HMA", "RMA", "VWMA"], title = "MA1 Type", group = "Moving Average 1")
float FirstMA = switch FirstMAType
    "SMA" => ta.sma(FirstMASource, FirstMALength)
    "EMA" => ta.ema(FirstMASource, FirstMALength)
    "WMA" => ta.wma(FirstMASource, FirstMALength)
    "HMA" => ta.hma(FirstMASource, FirstMALength)
    "RMA" => ta.rma(FirstMASource, FirstMALength)
    "VWMA" => ta.vwma(FirstMASource, FirstMALength)
SecondMATF = input.timeframe("5", title = "MA2 Timeframe", group = "Moving Average 2")
SecondMASource = input(close, title = "MA2 Source", group = "Moving Average 2")
SecondMALength = input.int(20, title = "MA2 Length", group = "Moving Average 2")
string SecondMAType = input.string(defval = "SMA", options = ["SMA", "EMA", "WMA", "HMA", "RMA", "VWMA"], title = "MA2 Type", group = "Moving Average 2")
float SecondMA = switch SecondMAType
    "SMA" => ta.sma(SecondMASource, SecondMALength)
    "EMA" => ta.ema(SecondMASource, SecondMALength)
    "WMA" => ta.wma(SecondMASource, SecondMALength)
    "HMA" => ta.hma(SecondMASource, SecondMALength)
    "RMA" => ta.rma(SecondMASource, SecondMALength)
    "VWMA" => ta.vwma(SecondMASource, SecondMALength)
ThirdMATF = input.timeframe("5", title = "MA3 Timeframe", group = "Moving Average 3")
ThirdMASource = input(close, title = "MA3 Source", group = "Moving Average 3")
ThirdMALength = input.int(200, title = "MA3 Length", group = "Moving Average 3")
string ThirdMAType = input.string(defval = "SMA", options = ["SMA", "EMA", "WMA", "HMA", "RMA", "VWMA"], title = "MA3 Type", group = "Moving Average 3")
float ThirdMA = switch ThirdMAType
    "SMA" => ta.sma(ThirdMASource, ThirdMALength)
    "EMA" => ta.ema(ThirdMASource, ThirdMALength)
    "WMA" => ta.wma(ThirdMASource, ThirdMALength)
    "HMA" => ta.hma(ThirdMASource, ThirdMALength)
    "RMA" => ta.rma(ThirdMASource, ThirdMALength)
    "VWMA" => ta.vwma(ThirdMASource, ThirdMALength)
FourthMATF = input.timeframe("", title = "MA4 Timeframe", group = "Moving Average 4 or VWAP")
FourthMASource = input(hlc3, title = "MA4 Source", group = "Moving Average 4 or VWAP")
FourthMALength = input.int(250, title = "MA4 Length", group = "Moving Average 4 or VWAP")
string FourthMAType = input.string(defval = "VWAP", options = ["SMA", "EMA", "WMA", "HMA", "RMA", "VWMA", "SWMA", "VWAP"], title = "MA4 Type or VWAP", group = "Moving Average 4 or VWAP")
float FourthMA = switch FourthMAType
    "SMA" => ta.sma(FourthMASource, FourthMALength)
    "EMA" => ta.ema(FourthMASource, FourthMALength)
    "WMA" => ta.wma(FourthMASource, FourthMALength)
    "HMA" => ta.hma(FourthMASource, FourthMALength)
    "RMA" => ta.rma(FourthMASource, FourthMALength)
    "VWMA" => ta.vwma(FourthMASource, FourthMALength)
    "SWMA" => ta.swma(FourthMASource)
    "VWAP" => ta.vwap(FourthMASource)
plot(request.security(syminfo.tickerid, FirstMATF, FirstMA), color = color.new(color.aqua, 0), linewidth = 1, title = "Show MA1")
plot(request.security(syminfo.tickerid, SecondMATF, SecondMA), color = color.new(color.maroon, 0), linewidth = 1, title = "Show MA2")
plot(request.security(syminfo.tickerid, ThirdMATF, ThirdMA), color = color.new(color.orange, 0), linewidth = 1, title = "Show MA3")
plot(request.security(syminfo.tickerid, FourthMATF, FourthMA), color = color.new(color.fuchsia, 0), linewidth = 1, title = "Show MA4 or VWAP")
