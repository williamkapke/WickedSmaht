// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Â© MarketKap

// Changelog:
// 2023-03-25 vhawkx - added customizable colors and lines
// 2023-04-06 MarketKap - added SMAs
// 2023-04-15 vhawkx - added EMA and VWAP options and 1m and 5m timeframes for MAs
// 2023-04-21 MarketKap - Switched to High Time Frame Candles and DRYed up the code

//@version=5

indicator("WST DB 5-on-1", overlay = true, max_boxes_count = 156, max_lines_count = 195)
import MarketKap/HTFCandlesLib/3 as big_candles

get_line_style(style) =>
    switch style
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// float ma1 = get_ma(ma1time, ma1length, ma1type, ma1src)
get_ma(ma_time, ma_length, ma_type, ma_src) =>
    switch ma_type
        "SMA" => ta.sma(ma_src, ma_length * ma_time)
        "EMA" => ta.ema(ma_src, ma_length * ma_time)
        "VWAP" => ta.vwap(ma_src)

//#region Higher Timeframe Candles
var tf_1a = input.timeframe('1', 'IF ON', inline = 'tf1')
var tf_1b = input.timeframe('5', 'CHART, USE', inline = 'tf1')
var down_color = input.color(#DE5E5788, title = "Candle Down Color")
var up_color = input.color(#52A49A88, title = "Candle Up Color")

var doubles_line_color = input.color(color.new(color.white, 30), title = "", group = "Double Top/Bottom Line", inline = "doubles")
var doubles_line_width = input.int(3, minval = 1, maxval = 5, title = "", group = "Double Top/Bottom Line", inline = "doubles")
var doubles_line_style = get_line_style(input.string("Solid", options = ["Solid", "Dotted", "Dashed"], title = "", group = "Double Top/Bottom Line", inline = "doubles"))
var doubles_offset = input.int(0, 'Offset', 0, 10, group = 'Double Top/Bottom Line', inline = "doubles")

var db_line_color = input.color(color.new(color.yellow, 30), title = "", group = "Double Barrel Conservative Entry Line", inline = "db")
var db_line_width = input.int(2, minval = 1, maxval = 5, title = "", group = "Double Barrel Conservative Entry Line", inline = "db")
var db_line_style = get_line_style(input.string("Solid", options = ["Solid", "Dotted", "Dashed"], title = "", group = "Double Barrel Conservative Entry Line", inline = "db"))


var tf = timeframe.period == tf_1a ? tf_1b : '1s' //use 1s to disable it
var htf = big_candles.create(tf, down_color, up_color, doubles_line_color, doubles_line_width, doubles_offset)
htf.update()
htf.doubles_line.set_style(doubles_line_style)
//#endregion


//#region Conservative Entry Line
var chart_tf_seconds = timeframe.in_seconds(timeframe.period)
var was_double = false
var is_double = false
if ta.change(htf.current.start_time)
    was_double := is_double
    if was_double
        number_of_candles_in_group = math.min(500, htf.timeframe_seconds / chart_tf_seconds) // tv only allows to draw 500 bars in the future
        start = htf.previous.start + int(number_of_candles_in_group/2)
        line.new(start, close[1], bar_index + number_of_candles_in_group - 1, close[1], color = db_line_color, width = db_line_width, style = db_line_style)
is_double := htf.current.color != htf.previous.color
//#endregion


//#region SMAs
float ma1 = get_ma(
     input.int(5, 'Timeframe', [1, 5], tooltip = "Choose between 1m or 5m timeframes.", group = "Moving Average 1"),
     input(9, 'Type', group = "Moving Average 1", inline = "MA Type"),
     input.string(defval = "SMA", options = ["SMA", "EMA"], title = "", group = "Moving Average 1", inline = "MA Type"),
     input(close, '', group = "Moving Average 1", inline = "MA Type")
 )
var ma1color = input.color(#FFFF0066, 'Style', group = "Moving Average 1", inline = "MA Style")
var ma1style = input.string('Dashed', '', ['Dashed', 'Solid'], group = "Moving Average 1", inline = "MA Style")

float ma2 = get_ma(
     input.int(5, 'Timeframe', [1, 5], tooltip = "Choose between 1m or 5m timeframes.", group = "Moving Average 2"),
     input(20, 'Type', group = "Moving Average 2", inline = "MA Type"),
     input.string(defval = "SMA", options = ["SMA", "EMA"], title = "", group = "Moving Average 2", inline = "MA Type"),
     input(close, '', group = "Moving Average 2", inline = "MA Type")
 )
var ma2color = input.color(#0000FFAA, 'Style', group = "Moving Average 2", inline = "MA Style")
var ma2style = input.string('Dashed', '', ['Dashed', 'Solid'], group = "Moving Average 2", inline = "MA Style")

float ma3 = get_ma(
     input.int(5, 'Timeframe', [1, 5], tooltip = "Choose between 1m or 5m timeframes.", group = "Moving Average 3"),
     input(200, 'Type', group = "Moving Average 3", inline = "MA Type"),
     input.string(defval = "SMA", options = ["SMA", "EMA"], title = "", group = "Moving Average 3", inline = "MA Type"),
     input(close, '', group = "Moving Average 3", inline = "MA Type")
 )
var ma3color = input.color(#00FFFF99, 'Style', group = "Moving Average 3", inline = "MA Style")
var ma3style = input.string('Dashed', '', ['Dashed', 'Solid'], group = "Moving Average 3", inline = "MA Style")

float ma4 = get_ma(
     input.int(5, 'Timeframe', [1, 5], tooltip = "Choose between 1m or 5m timeframes.", group = "Moving Average 4 or VWAP"),
     input(250, 'Type', group = "Moving Average 4 or VWAP", inline = "MA Type"),
     input.string(defval = "VWAP", options = ["SMA", "EMA", "VWAP"], title = "", group = "Moving Average 4 or VWAP", inline = "MA Type"),
     input(hlc3, '', group = "Moving Average 4 or VWAP", inline = "MA Type")
 )
var ma4color = input.color(#E040FB, 'Style', group = "Moving Average 4 or VWAP", inline = "MA Style")
var ma4style = input.string('Dashed', '', ['Dashed', 'Solid'], group = "Moving Average 4 or VWAP", inline = "MA Style")

get_ma_line_color(s, c) =>
    s == 'Solid' or bar_index % 2 == 0 ? c : #00000000

var isOneMin = timeframe.period == '1'
plot(isOneMin ? ma1 : na, "MA 1", get_ma_line_color(ma1style, ma1color))
plot(isOneMin ? ma2 : na, "MA 2", get_ma_line_color(ma2style, ma2color))
plot(isOneMin ? ma3 : na, "MA 3", get_ma_line_color(ma3style, ma3color))
plot(isOneMin ? ma4 : na, "MA 4 or VWAP", get_ma_line_color(ma4style, ma4color))
//#endregion
