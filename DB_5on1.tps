// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Â© MarketKap

// Changelog:
// vhawkx - added customizable colors and lines 2023-03-25
// MarketKap - added SMAs 2023-04-06
// vhawkx - added EMA and VWAP options 2023-04-15

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

var ma1color = input.color(#FFFF0066, 'Color', group = "5 min MA 1")
var ma1style = input.string('Dashed', 'Style', ['Dashed', 'Solid'], group = "5 min MA 1")
var ma1length = input(9, 'Length', group = "5 min MA 1")
ma1src = input(close, 'Source', group = "5 min MA 1")
string ma1type = input.string(defval = "SMA", options = ["SMA", "EMA"], title = "Type", group = "5 min MA 1")
float ma1 = switch ma1type
    "SMA" => ta.sma(ma1src, ma1length * 5)
    "EMA" => ta.ema(ma1src, ma1length * 5)

var ma2color = input.color(#0000FFAA, 'Color', group = "5 min MA 2")
var ma2style = input.string('Dashed', 'Style', ['Dashed', 'Solid'], group = "5 min MA 2")
var ma2length = input(20, 'Length', group = "5 min MA 2")
ma2src = input(close, 'Source', group = "5 min MA 2")
string ma2type = input.string(defval = "SMA", options = ["SMA", "EMA"], title = "Type", group = "5 min MA 2")
float ma2 = switch ma2type
    "SMA" => ta.sma(ma2src, ma2length * 5)
    "EMA" => ta.ema(ma2src, ma2length * 5)

var ma3color = input.color(#00FFFF99, 'Color', group = "5min MA 3")
var ma3style = input.string('Dashed', 'Style', ['Dashed', 'Solid'], group = "5min MA 3")
var ma3length = input(200, 'Length', group = "5min MA 3")
ma3src = input(close, 'Source', group = "5min MA 3")
string ma3type = input.string(defval = "SMA", options = ["SMA", "EMA"], title = "Type", group = "5min MA 3")
float ma3 = switch ma3type
    "SMA" => ta.sma(ma3src, ma3length * 5)
    "EMA" => ta.ema(ma3src, ma3length * 5)

var ma4color = input.color(#E040FB, 'Color', group = "5m MA 4 or VWAP")
var ma4style = input.string('Solid', 'Style', ['Dashed', 'Solid'], group = "5m MA 4 or VWAP")
var ma4length = input(250, 'Length', group = "5m MA 4 or VWAP")
ma4src = input(hlc3, 'Source', group = "5m MA 4 or VWAP")
string ma4type = input.string(defval = "VWAP", options = ["SMA", "EMA", "VWAP"], title = "Type", group = "5m MA 4 or VWAP")
float ma4 = switch ma4type
    "SMA" => ta.sma(ma4src, ma4length * 5)
    "EMA" => ta.ema(ma4src, ma4length * 5)
    "VWAP" => ta.vwap(ma4src)

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

c1 = ma1style == 'Solid' or bar_index % 2 == 0 ? ma1color : #00000000
c2 = ma2style == 'Solid' or bar_index % 2 == 0 ? ma2color : #00000000
c3 = ma3style == 'Solid' or bar_index % 2 == 0 ? ma3color : #00000000
c4 = ma4style == 'Solid' or bar_index % 2 == 0 ? ma4color : #00000000

plot(isOneMin ? ma1 : na, "MA 1", c1)
plot(isOneMin ? ma2 : na, "MA 2", c2)
plot(isOneMin ? ma3 : na, "MA 3", c3)
plot(isOneMin ? ma4 : na, "MA 4 or VWAP", c4)
