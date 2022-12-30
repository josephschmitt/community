"""
Applet: MN Metro Transit
Summary: Train, BRT, ABRT, and Bus Departure Times
Description: Shows Transit Departure Times from Selected Stop.
Author: Alex Miller & Jonathan Wescott
"""

load("render.star", "render")
load("http.star", "http")
load("encoding/json.star", "json")
load("schema.star", "schema")

#Assign Default Stop Code
DEFAULT_STOP_CODE = "15264"

def main(config):
    #Establish API URL
    stop_code = config.get("stop_code", DEFAULT_STOP_CODE)
    url = "https://svc.metrotransit.org/NexTripv2/" + stop_code + "?format=json"
    MTT = http.get(url).json()

    CB = "#333"
    CB2 = "#333"
    CT = "#fa0"
    CT2 = "#fa0"

    #invalid stop code page
    if "title" in MTT:
        stopDesc = "Invalid Stop Number"
        route1 = "Error"
        route2 = "Error"
        r1Desc = "400"
        r2Desc = "400"
        CB = "#222"
        CB2 = "#222"
        CT = "#F00"
        CT2 = "#FFF"
        depText1 = "Bad"
        depText2 = "Stop#"

        #no transit page
    elif len(MTT["departures"]) == 0:
        stopDesc = MTT["stops"][0]["description"]
        route1 = "  No"
        route2 = "  No"
        r1Desc = "   departures"
        r2Desc = "   departures"
        CB = "#222"
        CB2 = "#222"
        CT = "#777"
        CT2 = "#777"
        depText1 = ""
        depText2 = ""

        #only 1 more departure
    elif len(MTT["departures"]) == 1:
        stopDesc = MTT["stops"][0]["description"]
        route1 = MTT["departures"][0]["route_short_name"]
        route2 = " No"
        r1Desc = MTT["departures"][0]["direction_text"]
        r2Desc = "   departures "
        depText1 = MTT["departures"][0]["departure_text"]
        depText2 = ""
        CB = "#333"
        CB2 = "#222"
        CT = "#fa0"
        CT2 = "#777"

        #normal functioning page
    else:
        #departure slot 1
        #Find color and destination of first and second train and use that for rendering square color and 3 letter destination code
        stopDesc = MTT["stops"][0]["description"]
        route1 = MTT["departures"][0]["route_short_name"]
        route2 = MTT["departures"][1]["route_short_name"]
        r1Desc = MTT["departures"][0]["direction_text"]
        r2Desc = MTT["departures"][1]["direction_text"]
        depText1 = MTT["departures"][0]["departure_text"]
        depText2 = MTT["departures"][1]["departure_text"]

    if r1Desc == "NB":
        r1Desc = "North"
    elif r1Desc == "WB":
        r1Desc = "West"
    elif r1Desc == "SB":
        r1Desc = "South"
    elif r1Desc == "EB":
        r1Desc = "East"
    if r2Desc == "NB":
        r2Desc = "North"
    elif r2Desc == "WB":
        r2Desc = "West"
    elif r2Desc == "SB":
        r2Desc = "South"
    elif r2Desc == "EB":
        r2Desc = "East"

    if route1 == "Blue":
        CB = "#00a"
        CT = "#FFF"

    elif route1 == "Green":
        CB = "#070"
        CT = "#FFF"

    elif route1 == "Orange":
        CB = "#fa0"
        CT = "#222"

    elif route1 == "Red":
        CB = "#F00"
        CT = "#222"

    if route1[2:7] == "Line":
        CB = "#555"
        CT = "#FFF"

    #departure slot 2
    if route2 == "Blue":
        CB2 = "#00a"
        CT2 = "#FFF"

    elif route2 == "Green":
        CB2 = "#070"
        CT2 = "#FFF"

    elif route2 == "Orange":
        CB2 = "#fa0"
        CT2 = "#222"

    elif route2 == "Red":
        CB2 = "#F00"
        CT2 = "#222"

    if route2[2:7] == "Line":
        CB2 = "#555"
        CT2 = "#FFF"

    return render.Root(
        child = render.Column(
            children = [
                render.Marquee(
                    width = 64,
                    child = render.Text(stopDesc, font = "tb-8"),
                    offset_start = 5,
                    offset_end = 5,
                ),
                render.Box(width = 64, height = 1, color = CB),
                render.Row(
                    children = [
                        render.Column(
                            children = [
                                render.Box(width = 1, height = 11, color = CB),
                            ],
                        ),
                        render.Stack(
                            children = [
                                render.Box(width = 24, height = 11, color = CB),
                                render.Column(
                                    cross_align = "center",
                                    children = [
                                        render.Text(route1, font = "CG-pixel-3x5-mono", color = CT),
                                        render.Box(width = 24, height = 1, color = CB),
                                        render.Text(r1Desc, font = "CG-pixel-3x5-mono", color = CT),
                                    ],
                                ),
                            ],
                        ),
                        render.Box(width = 3, height = 10),
                        render.Text(depText1, font = "Dina_r400-6"),
                    ],
                ),
                render.Box(width = 64, height = 1, color = CB2),
                render.Row(
                    children = [
                        render.Column(
                            children = [
                                render.Box(width = 1, height = 11, color = CB2),
                            ],
                        ),
                        render.Stack(
                            children = [
                                render.Box(width = 24, height = 11, color = CB2),
                                render.Column(
                                    cross_align = "center",
                                    children = [
                                        render.Text(route2, font = "CG-pixel-3x5-mono", color = CT2),
                                        render.Box(width = 24, height = 1, color = CB2),
                                        render.Text(r2Desc, font = "CG-pixel-3x5-mono", color = CT2),
                                    ],
                                ),
                            ],
                        ),
                        render.Box(width = 3, height = 10),
                        render.Text(depText2, font = "Dina_r400-6"),
                    ],
                ),
                render.Box(width = 64, height = 1, color = "#a00"),
            ],
        ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "stop_code",
                name = "Stop ID",
                desc = "Station's Stop ID from (https://www.metrotransit.org/stops-stations)",
                icon = "trainTram",
            ),
        ],
    )
