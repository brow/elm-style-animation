module Style.PropertyHelpers exposing (Static, Dynamic, Physics, Style,  baseName, is, id, toStatic, toDynamic, update, updateFrom, updateOver, render, renderAttr, emptyEasing) --where

import Style.Properties exposing (..)
import Style.Spring as Spring
import Color as ElmColor
import Time exposing (Time, second)
import String 
import Svg.Attributes as Svg

{-| Represent a CSS style as a list of style properties with concrete values.
-}
type alias Style =
    List Static


type alias Physics =
    { physical : Spring.Physical
    , spring : Spring.Model
    , easing : Maybe Easing
    }


type alias Easing =
    { ease : Float -> Float
    , counterForce : Spring.Model
    , counterForcePhys : Maybe Spring.Physical
    , duration : Time
    }


emptyPhysics : Physics
emptyPhysics =
    { physical =
        { position = 0
        , velocity = 0
        }
    , spring =
        { stiffness = 170
        , damping = 26
        , destination = 1
        }
    , easing = Nothing
    }

emptyEasing =
    { ease = defaultEasing
    , counterForce =
        { stiffness = 170
        , damping = 26
        , destination = 1
        }
    , counterForcePhys = Nothing
    , duration = defaultDuration
    }


defaultDuration : Float
defaultDuration =
    0.35 * second


defaultEasing : Float -> Float
defaultEasing x =
    (1 - cos (pi * x)) / 2


type DynamicColor =
        RGBA Physics Physics Physics Physics

emptyDynamicColor : DynamicColor
emptyDynamicColor = RGBA emptyPhysics emptyPhysics emptyPhysics emptyPhysics

type alias Dynamic = Property Physics DynamicColor
type alias Static = Property Float ElmColor.Color 



{-| Render style properties into their css values.

-}
--render : List (Property Float) -> List ( String, String )
render styleProps =
    let
        rendered =
            List.map (\prop -> ( name prop, value prop )) styleProps

        props =
            List.filter (\( name, _ ) -> name /= "transform") rendered

        transforms =
            List.map (snd)
                <| List.filter (\( name, _ ) -> name == "transform") rendered

        combinedTransforms =
            if List.length transforms == 0 then
                []
            else
                [ ( "transform"
                  , String.concat
                        (List.intersperse " "
                            transforms
                        )
                  )
                ]
    in
        List.concatMap prefix (props ++ combinedTransforms)


renderAttr styles =
    let
        toAttr prop =
            case prop of 
                X a -> Just <| Svg.x (toString a)
                Y a -> Just <| Svg.y (toString a)
                Cx a -> Just <| Svg.cx (toString a)
                Cy a -> Just <| Svg.cy (toString a)
                R a -> Just <| Svg.r (toString a)
                Rx a -> Just <| Svg.rx (toString a)
                Ry a -> Just <| Svg.ry (toString a)
                D a -> Just <| Svg.d (toString a)
                Points a -> Just <| Svg.points (String.concat <| List.intersperse ", " <| List.map toString a)
                Width a _ -> Just <| Svg.width (toString a)
                Height a _ -> Just <| Svg.height (toString a)
                _ -> Nothing
    in
        List.filterMap toAttr styles


name : Property a b -> String
name styleProp =
    case styleProp of
        Display _ ->
            "display"

        Opacity _ ->
            "opacity"

        Height _ _ ->
            "height"

        Width _ _ ->
            "width"

        Left _ _ ->
            "left"

        Right _ _ ->
            "right"

        Bottom _ _ ->
            "bottom"

        Top _ _ ->
            "top"

        MaxHeight _ _ ->
            "max-height"

        MaxWidth _ _ ->
            "max-width"

        MinHeight _ _ ->
            "min-height"

        MinWidth _ _ ->
            "min-width"

        Padding _ _ ->
            "padding"

        PaddingLeft _ _ ->
            "padding-left"

        PaddingRight _ _ ->
            "padding-right"

        PaddingTop _ _ ->
            "padding-top"

        PaddingBottom _ _ ->
            "padding-bottom"

        Margin _ _ ->
            "margin"

        MarginLeft _ _ ->
            "margin-left"

        MarginRight _ _ ->
            "margin-right"

        MarginTop _ _ ->
            "margin-top"

        MarginBottom _ _ ->
            "margin-bottom"

        BorderWidth _ _ ->
            "border-width"

        BorderRadius _ _ ->
            "border-radius"

        BorderTopLeftRadius _ _ ->
            "border-top-left-radius"

        BorderTopRightRadius _ _ ->
            "border-top-right-radius"

        BorderBottomLeftRadius _ _ ->
            "border-bottom-left-radius"

        BorderBottomRightRadius _ _ ->
            "border-bottom-right-radius"

        LetterSpacing _ _ ->
            "letter-spacing"

        LineHeight _ _ ->
            "line-height"

        BackgroundPosition _ _ _ ->
            "background-position"

        TransformOrigin _ _ _ _ ->
            "transform-origin"

        Color _ ->
            "color"

        BackgroundColor _ ->
            "background-color"

        BorderColor _ ->
            "border-color"

        Matrix _ _ _ _ _ _ ->
            "transform"

        Matrix3d _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ ->
            "transform"

        Translate _ _ _ ->
            "transform"

        Translate3d _ _ _ _ ->
            "transform"

        TranslateX _ _ ->
            "transform"

        TranslateY _ _ ->
            "transform"

        Scale _ ->
            "transform"

        Scale3d _ _ _ ->
            "transform"

        ScaleX _ ->
            "transform"

        ScaleY _ ->
            "transform"

        ScaleZ _ ->
            "transform"

        Rotate _ _ ->
            "transform"

        Rotate3d _ _ _ _ _ ->
            "transform"

        RotateX _ _ ->
            "transform"

        RotateY _ _ ->
            "transform"

        Skew _ _ _ ->
            "transform"

        SkewX _ _ ->
            "transform"

        SkewY _ _ ->
            "transform"

        Perspective _ ->
            "transform"

        X _ -> "x"
        Y _ -> "y"
        Cx _ -> "cx"
        Cy _ -> "cy"
        R _ -> "r"
        Rx _ -> "rx"
        Ry _ -> "ry"
        D _ -> "d"
        Points _ -> "points" 



-- renders a valid css value for a Style Property


value : Static -> String
value prop =
    let
        val a =
            toString a

        renderLength a unit =
            (val a) ++ lenUnit unit

        renderAngle a unit =
            (val a) ++ angleUnit unit

        renderList xs =
            "("
                ++ (String.concat
                        <| List.intersperse ","
                        <| List.map toString xs
                   )
                ++ ")"
    in
        case prop of
            Display mode ->
                displayMode mode

            Opacity a ->
                val a

            Height a unit ->
                renderLength a unit

            Width a unit ->
                renderLength a unit

            Left a unit ->
                renderLength a unit

            Top a unit ->
                renderLength a unit

            Right a unit ->
                renderLength a unit

            Bottom a unit ->
                renderLength a unit

            MaxHeight a unit ->
                renderLength a unit

            MaxWidth a unit ->
                renderLength a unit

            MinHeight a unit ->
                renderLength a unit

            MinWidth a unit ->
                renderLength a unit

            Padding a unit ->
                renderLength a unit

            PaddingLeft a unit ->
                renderLength a unit

            PaddingRight a unit ->
                renderLength a unit

            PaddingTop a unit ->
                renderLength a unit

            PaddingBottom a unit ->
                renderLength a unit

            Margin a unit ->
                renderLength a unit

            MarginLeft a unit ->
                renderLength a unit

            MarginRight a unit ->
                renderLength a unit

            MarginTop a unit ->
                renderLength a unit

            MarginBottom a unit ->
                renderLength a unit

            BorderWidth a unit ->
                renderLength a unit

            BorderRadius a unit ->
                renderLength a unit

            BorderTopLeftRadius a unit ->
                renderLength a unit

            BorderTopRightRadius a unit ->
                renderLength a unit

            BorderBottomLeftRadius a unit ->
                renderLength a unit

            BorderBottomRightRadius a unit ->
                renderLength a unit

            LetterSpacing a unit ->
                renderLength a unit

            LineHeight a unit ->
                renderLength a unit

            BackgroundPosition x y unit ->
                renderLength x unit
                    ++ " "
                    ++ renderLength y unit

            TransformOrigin x y z unit ->
                renderLength x unit
                    ++ " "
                    ++ renderLength y unit
                    ++ " "
                    ++ renderLength z unit

            Color color ->
                renderColor color

            BackgroundColor color ->
                renderColor color

            BorderColor color ->
                renderColor color

            Translate a1 a2 unit ->
                "translate("
                    ++ (renderLength a1 unit)
                    ++ ","
                    ++ (renderLength a2 unit)
                    ++ ")"

            Translate3d a1 a2 a3 unit ->
                "translate3d("
                    ++ (renderLength a1 unit)
                    ++ ","
                    ++ (renderLength a2 unit)
                    ++ ","
                    ++ (renderLength a3 unit)
                    ++ ")"

            TranslateX a unit ->
                "translateX(" ++ renderLength a unit ++ ")"

            TranslateY a unit ->
                "translateY(" ++ renderLength a unit ++ ")"

            Scale a1 ->
                "scale(" ++ (val a1) ++ ")"

            Scale3d a1 a2 a3 ->
                "scale3d("
                    ++ (val a1)
                    ++ ","
                    ++ (val a2)
                    ++ ","
                    ++ (val a3)
                    ++ ")"

            ScaleX a ->
                "scaleX(" ++ val a ++ ")"

            ScaleY a ->
                "scaleY(" ++ val a ++ ")"

            ScaleZ a ->
                "scaleZ(" ++ val a ++ ")"

            Rotate a unit ->
                "rotate(" ++ renderAngle a unit ++ ")"

            Rotate3d a1 a2 a3 a4 unit ->
                "rotate3d("
                    ++ (val a1)
                    ++ ","
                    ++ (val a2)
                    ++ ","
                    ++ (val a3)
                    ++ ","
                    ++ (renderAngle a4 unit)
                    ++ ")"

            RotateX a unit ->
                "rotateX(" ++ renderAngle a unit ++ ")"

            RotateY a unit ->
                "rotateY(" ++ renderAngle a unit ++ ")"

            Skew a1 a2 unit ->
                "skew("
                    ++ (renderAngle a1 unit)
                    ++ ","
                    ++ (renderAngle a2 unit)
                    ++ ")"

            SkewX a unit ->
                "skewX(" ++ renderAngle a unit ++ ")"

            SkewY a unit ->
                "skewY(" ++ renderAngle a unit ++ ")"

            Perspective a ->
                "perspective(" ++ (val a) ++ ")"

            Matrix a b c x y z ->
                "matrix"
                    ++ (renderList [ a, b, c, x, y, z ])

            Matrix3d a b c d e f g h i j k l m n o p ->
                "matrix3d"
                    ++ (renderList [ a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p ])

            X a -> toString a
            Y a -> toString a
            Cx a -> toString a
            Cy a -> toString a
            R a -> toString a
            Rx a -> toString a
            Ry a -> toString a
            D a -> toString a
            Points pts -> renderList pts







renderColor : ElmColor.Color -> String
renderColor color =
        let
            rgba = ElmColor.toRgb color
        in
        "rgba("
            ++ toString rgba.red
            ++ ","
            ++ toString rgba.green
            ++ ","
            ++ toString rgba.blue
            ++ ","
            ++ toString rgba.alpha
            ++ ")"


--renderColor' : Float -> Float -> Float -> Float -> String
--renderColor' x y z a =
--    let
--        renderList xs =
--            "("
--                ++ (String.concat
--                        <| List.intersperse ","
--                        <| List.map toString xs
--                   )
--                ++ ")"

--        renderIntList xs =
--            renderList <| List.map round xs
--    in
--        "rgba("
--            ++ toString (round x)
--            ++ ","
--            ++ toString (round y)
--            ++ ","
--            ++ toString (round z)
--            ++ ","
--            ++ toString a
--            ++ ")"


iePrefix : String
iePrefix =
    "-ms-"


webkitPrefix : String
webkitPrefix =
    "-webkit-"


{-| Add a prefix to a name/value pair, if needed.

-}
prefix : ( String, String ) -> List ( String, String )
prefix stylePair =
    let
        propName =
            fst stylePair

        propValue =
            snd stylePair
    in
        case propName of
            "transform" ->
                [ stylePair
                , ( iePrefix ++ propName, propValue )
                , ( webkitPrefix ++ propName, propValue )
                ]

            "transform-origin" ->
                [ stylePair
                , ( iePrefix ++ propName, propValue )
                , ( webkitPrefix ++ propName, propValue )
                ]

            _ ->
                [ stylePair ]


{-| Used to match properties without units so that mismatched units can be detected.

-}
baseName : Property a b -> String
baseName prop =
    case prop of
        Display _ ->
            "display"

        Opacity _ ->
            "opacity"

        Height _ _ ->
            "height"

        Width _ _ ->
            "width"

        Left _ _ ->
            "left"

        Right _ _ ->
            "right"

        Bottom _ _ ->
            "bottom"

        Top _ _ ->
            "top"

        MaxHeight _ _ ->
            "max-height"

        MaxWidth _ _ ->
            "max-width"

        MinHeight _ _ ->
            "min-height"

        MinWidth _ _ ->
            "min-width"

        Padding _ _ ->
            "padding"

        PaddingLeft _ _ ->
            "padding-left"

        PaddingRight _ _ ->
            "padding-right"

        PaddingTop _ _ ->
            "padding-top"

        PaddingBottom _ _ ->
            "padding-bottom"

        Margin _ _ ->
            "margin"

        MarginLeft _ _ ->
            "margin-left"

        MarginRight _ _ ->
            "margin-right"

        MarginTop _ _ ->
            "margin-top"

        MarginBottom _ _ ->
            "margin-bottom"

        BorderWidth _ _ ->
            "border-width"

        BorderRadius _ _ ->
            "border-radius"

        BorderTopLeftRadius _ _ ->
            "border-top-left-radius"

        BorderTopRightRadius _ _ ->
            "border-top-right-radius"

        BorderBottomLeftRadius _ _ ->
            "border-bottom-left-radius"

        BorderBottomRightRadius _ _ ->
            "border-bottom-right-radius"

        LetterSpacing _ _ ->
            "letter-spacing"

        LineHeight _ _ ->
            "line-height"

        BackgroundPosition _ _ _ ->
            "background-position"

        Color _ ->
            "color"

        BackgroundColor _ ->
            "background-color"

        BorderColor _ ->
            "border-color"

        TransformOrigin _ _ _ _ ->
            "transform-origin"

        Matrix _ _ _ _ _ _ ->
            "matrix"

        Matrix3d _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ ->
            "matrix3d"

        Translate _ _ _ ->
            "translate"

        Translate3d _ _ _ _ ->
            "translate3d"

        TranslateX _ _ ->
            "translatex"

        TranslateY _ _ ->
            "translatey"

        Scale _ ->
            "scale"

        Scale3d _ _ _ ->
            "scale3d"

        ScaleX _ ->
            "scalex"

        ScaleY _ ->
            "scaley"

        ScaleZ _ ->
            "scalez"

        Rotate _ _ ->
            "rotate"

        Rotate3d _ _ _ _ _ ->
            "rotate3d"

        RotateX _ _ ->
            "rotatex"

        RotateY _ _ ->
            "rotatey"

        Skew _ _ _ ->
            "skew"

        SkewX _ _ ->
            "skewx"

        SkewY _ _ ->
            "skewy"

        Perspective _ ->
            "perspective"

        x -> id x


id : Property a b -> String
id prop =
    case prop of
        Opacity _ ->
            "opacity"

        Display _ ->
            "display"

        Height _ unit ->
            "height in " ++ lenUnit unit

        Width _ unit ->
            "width in " ++ lenUnit unit

        Left _ unit ->
            "left in " ++ lenUnit unit

        Right _ unit ->
            "right in " ++ lenUnit unit

        Bottom _ unit ->
            "bottom in " ++ lenUnit unit

        Top _ unit ->
            "top in " ++ lenUnit unit

        MaxHeight _ unit ->
            "max-height in " ++ lenUnit unit

        MaxWidth _ unit ->
            "max-width in " ++ lenUnit unit

        MinHeight _ unit ->
            "min-height in " ++ lenUnit unit

        MinWidth _ unit ->
            "min-width in " ++ lenUnit unit

        Padding _ unit ->
            "padding in " ++ lenUnit unit

        PaddingLeft _ unit ->
            "padding-left in " ++ lenUnit unit

        PaddingRight _ unit ->
            "padding-right in " ++ lenUnit unit

        PaddingTop _ unit ->
            "padding-top in " ++ lenUnit unit

        PaddingBottom _ unit ->
            "padding-bottom in " ++ lenUnit unit

        Margin _ unit ->
            "margin in " ++ lenUnit unit

        MarginLeft _ unit ->
            "margin-left in " ++ lenUnit unit

        MarginRight _ unit ->
            "margin-right in " ++ lenUnit unit

        MarginTop _ unit ->
            "margin-top in " ++ lenUnit unit

        MarginBottom _ unit ->
            "margin-bottom in " ++ lenUnit unit

        BorderWidth _ unit ->
            "border-width in " ++ lenUnit unit

        BorderRadius _ unit ->
            "border-radius in " ++ lenUnit unit

        BorderTopLeftRadius _ unit ->
            "border-top-left-radius in " ++ lenUnit unit

        BorderTopRightRadius _ unit ->
            "border-top-right-radius in " ++ lenUnit unit

        BorderBottomLeftRadius _ unit ->
            "border-bottom-left-radius in " ++ lenUnit unit

        BorderBottomRightRadius _ unit ->
            "border-bottom-right-radius in " ++ lenUnit unit

        LetterSpacing _ unit ->
            "letter-spacing in " ++ lenUnit unit

        LineHeight _ unit ->
            "line-height in " ++ lenUnit unit

        BackgroundPosition _ _ unit ->
            "background-position in " ++ lenUnit unit

        Color _ ->
            "color"

        BackgroundColor _ ->
            "background-color"

        BorderColor _ ->
            "border-color"

        TransformOrigin _ _ _ unit ->
            "transform-origin in " ++ lenUnit unit

        Matrix _ _ _ _ _ _ ->
            "matrix"

        Matrix3d _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ ->
            "matrix3d"

        Translate _ _ unit ->
            "translate in " ++ lenUnit unit

        Translate3d _ _ _ unit ->
            "translate3d in " ++ lenUnit unit

        TranslateX _ unit ->
            "translatex in " ++ lenUnit unit

        TranslateY _ unit ->
            "translatey in " ++ lenUnit unit

        Scale _ ->
            "scale"

        Scale3d _ _ _ ->
            "scale3d"

        ScaleX _ ->
            "scalex"

        ScaleY _ ->
            "scaley"

        ScaleZ _ ->
            "scalez"

        Rotate _ unit ->
            "rotate in " ++ angleUnit unit

        Rotate3d _ _ _ _ unit ->
            "rotate3d in " ++ angleUnit unit

        RotateX _ unit ->
            "rotatex in " ++ angleUnit unit

        RotateY _ unit ->
            "rotatey in " ++ angleUnit unit

        Skew _ _ unit ->
            "skew in " ++ angleUnit unit

        SkewX _ unit ->
            "skewx in " ++ angleUnit unit

        SkewY _ unit ->
            "skewy in " ++ angleUnit unit

        Perspective _ ->
            "perspective"
        X _ -> "x"
        Y _ -> "y"
        Cx _ -> "cx"
        Cy _ -> "cy"
        R _ -> "r"
        Rx _ -> "rx"
        Ry _ -> "ry"
        D _ -> "d"
        Points _ -> "points" 


lenUnit : Length -> String
lenUnit unit =
    case unit of
        Px ->
            "px"

        Percent ->
            "%"

        Rem ->
            "rem"

        Em ->
            "em"

        Ex ->
            "ex"

        Ch ->
            "ch"

        Vh ->
            "vh"

        Vw ->
            "vw"

        Vmin ->
            "vmin"

        Vmax ->
            "vmax"

        Mm ->
            "mm"

        Cm ->
            "cm"

        In ->
            "in"

        Pt ->
            "pt"

        Pc ->
            "pc"


angleUnit : Angle -> String
angleUnit unit =
    case unit of
        Deg ->
            "deg"

        Grad ->
            "grad"

        Rad ->
            "rad"

        Turn ->
            "turn"


displayMode : DisplayMode -> String
displayMode mode =
    case mode of
        None ->
            "none"

        Inline ->
            "inline"

        InlineBlock ->
            "inline-block"

        Block ->
            "block"

        Flex ->
            "flex"

        InlineFlex ->
            "inline-flex"

        ListItem ->
            "list-item"



-------------------------------
-- Mapping
-------------------------------

toStatic : Dynamic -> Static
toStatic prop = map (\phys -> phys.physical.position) toStaticColor prop


toStaticColor : DynamicColor -> ElmColor.Color
toStaticColor dynamic =
        case dynamic of 
            RGBA r g b a ->
                ElmColor.rgba (round r.physical.position) (round g.physical.position) (round b.physical.position) (a.physical.position)


toDynamic prop = map (\_ -> emptyPhysics) (\_ -> emptyDynamicColor) prop
--type alias Dynamic = Property Physics DynamicColor
--type alias Static = Property Float Color 

update : (Physics -> Physics) -> Dynamic -> Dynamic
update fn prop = 
                map fn 
                    (\dynamicColor -> 
                        case dynamicColor of 
                            RGBA r g b a ->
                                RGBA (fn r) (fn g) (fn b) (fn a)
                    )
                    prop


map : (a -> b) -> (colorA -> colorB) -> Property a colorA -> Property b colorB
map fn colorFn prop =
    case prop of
        Display mode ->
            Display mode

        Opacity a ->
            Opacity (fn a)

        Height a u ->
            Height (fn a) u

        Width a u ->
            Width (fn a) u

        Left a u ->
            Left (fn a) u

        Top a u ->
            Top (fn a) u

        Right a u ->
            Right (fn a) u

        Bottom a u ->
            Bottom (fn a) u

        MaxHeight a u ->
            MaxHeight (fn a) u

        MaxWidth a u ->
            MaxWidth (fn a) u

        MinHeight a u ->
            MinHeight (fn a) u

        MinWidth a u ->
            MinWidth (fn a) u

        Padding a u ->
            Padding (fn a) u

        PaddingLeft a u ->
            PaddingLeft (fn a) u

        PaddingRight a u ->
            PaddingRight (fn a) u

        PaddingTop a u ->
            PaddingTop (fn a) u

        PaddingBottom a u ->
            PaddingBottom (fn a) u

        Margin a u ->
            Margin (fn a) u

        MarginLeft a u ->
            MarginLeft (fn a) u

        MarginRight a u ->
            MarginRight (fn a) u

        MarginTop a u ->
            MarginTop (fn a) u

        MarginBottom a u ->
            MarginBottom (fn a) u

        BorderWidth a u ->
            BorderWidth (fn a) u

        BorderRadius a u ->
            BorderRadius (fn a) u

        BorderTopLeftRadius a u ->
            BorderTopLeftRadius (fn a) u

        BorderTopRightRadius a u ->
            BorderTopRightRadius (fn a) u

        BorderBottomLeftRadius a u ->
            BorderBottomLeftRadius (fn a) u

        BorderBottomRightRadius a u ->
            BorderBottomRightRadius (fn a) u

        LetterSpacing a u ->
            LetterSpacing (fn a) u

        LineHeight a u ->
            LineHeight (fn a) u

        BackgroundPosition x y u ->
            BackgroundPosition (fn x) (fn y) u

        TransformOrigin x y z u ->
            TransformOrigin (fn x) (fn y) (fn z) u

        Color color ->
            Color (colorFn color)

        BackgroundColor color ->
            BackgroundColor (colorFn color)

        BorderColor color ->
            BorderColor (colorFn color)

        Translate a1 a2 u ->
            Translate (fn a1) (fn a2) u

        Translate3d a1 a2 a3 u ->
            Translate3d (fn a1) (fn a2) (fn a3) u

        TranslateX a u ->
            TranslateX (fn a) u

        TranslateY a u ->
            TranslateY (fn a) u

        Scale a ->
            Scale (fn a)

        Scale3d a1 a2 a3 ->
            Scale3d (fn a1) (fn a2) (fn a3)

        ScaleX a ->
            ScaleX (fn a)

        ScaleY a ->
            ScaleY (fn a)

        ScaleZ a ->
            ScaleZ (fn a)

        Rotate a u ->
            Rotate (fn a) u

        Rotate3d a1 a2 a3 a4 u ->
            Rotate3d (fn a1) (fn a2) (fn a3) (fn a4) u

        RotateX a u ->
            RotateX (fn a) u

        RotateY a u ->
            RotateY (fn a) u

        Skew a1 a2 u ->
            Skew (fn a1) (fn a2) u

        SkewX a u ->
            SkewX (fn a) u

        SkewY a u ->
            SkewY (fn a) u

        Perspective a ->
            Perspective (fn a)

        Matrix a b c x y z ->
            Matrix (fn a) (fn b) (fn c) (fn x) (fn y) (fn z)

        Matrix3d a b c d e f g h i j k l m n o p ->
            Matrix3d (fn a) (fn b) (fn c) (fn d) (fn e) (fn f) (fn g) (fn h) (fn i) (fn j) (fn k) (fn l) (fn m) (fn n) (fn o) (fn p)

        X a -> X (fn a)
        Y a -> Y (fn a)
        Cx a -> Cx (fn a)
        Cy a -> Cy (fn a)
        R a -> R (fn a)
        Rx a -> Rx (fn a)
        Ry a -> Ry (fn a)
        D a -> D (fn a)
        Points a -> Points (List.map fn a)


is : (Physics -> Bool) -> Property Physics DynamicColor -> Bool
is pred prop =
    case prop of
        Display mode ->
            True

        Opacity a ->
            pred a

        Height a _ ->
            pred a

        Width a _ ->
            pred a

        Left a _ ->
            pred a

        Top a _ ->
            pred a

        Right a _ ->
            pred a

        Bottom a _ ->
            pred a

        MaxHeight a _ ->
            pred a

        MaxWidth a _ ->
            pred a

        MinHeight a _ ->
            pred a

        MinWidth a _ ->
            pred a

        Padding a _ ->
            pred a

        PaddingLeft a _ ->
            pred a

        PaddingRight a _ ->
            pred a

        PaddingTop a _ ->
            pred a

        PaddingBottom a _ ->
            pred a

        Margin a _ ->
            pred a

        MarginLeft a _ ->
            pred a

        MarginRight a _ ->
            pred a

        MarginTop a _ ->
            pred a

        MarginBottom a _ ->
            pred a

        BorderWidth a _ ->
            pred a

        BorderRadius a _ ->
            pred a

        BorderTopLeftRadius a _ ->
            pred a

        BorderTopRightRadius a _ ->
            pred a

        BorderBottomLeftRadius a _ ->
            pred a

        BorderBottomRightRadius a _ ->
            pred a

        LetterSpacing a _ ->
            pred a

        LineHeight a _ ->
            pred a

        BackgroundPosition x y _ ->
            pred x && pred y

        TransformOrigin x y z _ ->
            pred x && pred y && pred z

        Color color ->
            isColor pred color

        BackgroundColor color ->
            isColor pred color

        BorderColor color ->
            isColor pred color

        Translate a1 a2 _ ->
            pred a1 && pred a2

        Translate3d a1 a2 a3 _ ->
            pred a1 && pred a2 && pred a3

        TranslateX a _ ->
            pred a

        TranslateY a _ ->
            pred a

        Scale a1 ->
            pred a1

        Scale3d a1 a2 a3 ->
            pred a1 && pred a2 && pred a3

        ScaleX a ->
            pred a

        ScaleY a ->
            pred a

        ScaleZ a ->
            pred a

        Rotate a _ ->
            pred a

        Rotate3d a1 a2 a3 a4 _ ->
            pred a1 && pred a2 && pred a3 && pred a4

        RotateX a _ ->
            pred a

        RotateY a _ ->
            pred a

        Skew a1 a2 _ ->
            pred a1 && pred a2

        SkewX a _ ->
            pred a

        SkewY a _ ->
            pred a

        Perspective a ->
            pred a

        Matrix a b c x y z ->
            List.all pred [ a, b, c, x, y, z ]

        Matrix3d a b c d e f g h i j k l m n o p ->
            List.all pred [ a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p ]

        X a -> pred a
        Y a -> pred a
        Cx a -> pred a
        Cy a -> pred a
        R a -> pred a
        Rx a -> pred a
        Ry a -> pred a
        D a -> pred a
        Points a -> List.all pred a



isColor pred color =
    case color of
        RGBA r g b a ->
            pred r && pred g && pred b && pred a



updateFrom : (Physics -> Physics -> Physics) -> Dynamic -> Dynamic -> Dynamic
updateFrom fn prev prop =
            map2 
                fn
                (\prevDColor currentDColor -> 
                    case prevDColor of 
                        RGBA r1 g1 b1 a1 ->
                            case currentDColor of 
                                RGBA r2 g2 b2 a2 ->
                                    RGBA (fn r1 r2) (fn g1 g2) (fn b1 b2) (fn a1 a2)
                )
                prev
                prop


map2 : (a -> b -> b) -> (colorA -> colorB -> colorB) -> Property a colorA -> Property b colorB -> Property b colorB
map2 fn colorFn prev prop =
    case prev of

        Display _ ->
            prop

        Opacity a ->
            case prop of
                Opacity b ->
                    Opacity (fn a b)

                _ ->
                    prop

        Height a unit ->
            case prop of
                Height b _ ->
                    Height (fn a b) unit

                _ ->
                    prop

        Width a unit ->
            case prop of
                Width b _ ->
                    Width (fn a b) unit

                _ ->
                    prop

        Left a unit ->
            case prop of
                Left b _ ->
                    Left (fn a b) unit

                _ ->
                    prop

        Top a unit ->
            case prop of
                Top b _ ->
                    Top (fn a b) unit

                _ ->
                    prop

        Right a unit ->
            case prop of
                Right b _ ->
                    Right (fn a b) unit

                _ ->
                    prop

        Bottom a unit ->
            case prop of
                Bottom b _ ->
                    Bottom (fn a b) unit

                _ ->
                    prop

        MaxHeight a unit ->
            case prop of
                MaxHeight b _ ->
                    MaxHeight (fn a b) unit

                _ ->
                    prop

        MaxWidth a unit ->
            case prop of
                MaxWidth b _ ->
                    MaxWidth (fn a b) unit

                _ ->
                    prop

        MinHeight a unit ->
            case prop of
                MinHeight b _ ->
                    MinHeight (fn a b) unit

                _ ->
                    prop

        MinWidth a unit ->
            case prop of
                MinWidth b _ ->
                    MinWidth (fn a b) unit

                _ ->
                    prop

        Padding a unit ->
            case prop of
                Padding b _ ->
                    Padding (fn a b) unit

                _ ->
                    prop

        PaddingLeft a unit ->
            case prop of
                PaddingLeft b _ ->
                    PaddingLeft (fn a b) unit

                _ ->
                    prop

        PaddingRight a unit ->
            case prop of
                PaddingRight b _ ->
                    PaddingRight (fn a b) unit

                _ ->
                    prop

        PaddingTop a unit ->
            case prop of
                PaddingTop b _ ->
                    PaddingTop (fn a b) unit

                _ ->
                    prop

        PaddingBottom a unit ->
            case prop of
                PaddingBottom b _ ->
                    PaddingBottom (fn a b) unit

                _ ->
                    prop

        Margin a unit ->
            case prop of
                Margin b _ ->
                    Margin (fn a b) unit

                _ ->
                    prop

        MarginLeft a unit ->
            case prop of
                MarginLeft b _ ->
                    MarginLeft (fn a b) unit

                _ ->
                    prop

        MarginRight a unit ->
            case prop of
                MarginRight b _ ->
                    MarginRight (fn a b) unit

                _ ->
                    prop

        MarginTop a unit ->
            case prop of
                MarginTop b _ ->
                    MarginTop (fn a b) unit

                _ ->
                    prop

        MarginBottom a unit ->
            case prop of
                MarginBottom b _ ->
                    MarginBottom (fn a b) unit

                _ ->
                    prop

        BorderWidth a unit ->
            case prop of
                BorderWidth b _ ->
                    BorderWidth (fn a b) unit

                _ ->
                    prop

        BorderRadius a unit ->
            case prop of
                BorderRadius b _ ->
                    BorderRadius (fn a b) unit

                _ ->
                    prop

        BorderTopLeftRadius a unit ->
            case prop of
                BorderTopLeftRadius b _ ->
                    BorderTopLeftRadius (fn a b) unit

                _ ->
                    prop

        BorderTopRightRadius a unit ->
            case prop of
                BorderTopRightRadius b _ ->
                    BorderTopRightRadius (fn a b) unit

                _ ->
                    prop

        BorderBottomLeftRadius a unit ->
            case prop of
                BorderBottomLeftRadius b _ ->
                    BorderBottomLeftRadius (fn a b) unit

                _ ->
                    prop

        BorderBottomRightRadius a unit ->
            case prop of
                BorderBottomRightRadius b _ ->
                    BorderBottomRightRadius (fn a b) unit

                _ ->
                    prop

        LetterSpacing a unit ->
            case prop of
                LetterSpacing b _ ->
                    LetterSpacing (fn a b) unit

                _ ->
                    prop

        LineHeight a unit ->
            case prop of
                LineHeight b _ ->
                    LineHeight (fn a b) unit

                _ ->
                    prop

        BackgroundPosition x1 y1 unit ->
            case prop of
                BackgroundPosition x2 y2 _ ->
                    BackgroundPosition (fn x1 x2) (fn y1 y2) unit

                _ ->
                    prop

        Color color ->
            case prop of
                Color color2 ->
                    Color (colorFn color color2)
                _ ->
                    prop

        BorderColor color ->
            case prop of
                BorderColor color2 ->
                    BorderColor (colorFn color color2)
                _ ->
                    prop

        BackgroundColor color ->
            case prop of
                BackgroundColor color2 ->
                    BackgroundColor (colorFn color color2)
                _ ->
                    prop

        TransformOrigin x1 y1 z1 unit ->
            case prop of
                TransformOrigin x2 y2 z2 _ ->
                    TransformOrigin (fn x1 x2) (fn y1 y2) (fn z1 z2) unit

                _ ->
                    prop

        Translate x1 y1 unit ->
            case prop of
                Translate x2 y2 _ ->
                    Translate (fn x1 x2) (fn y1 y2) unit

                _ ->
                    prop

        Translate3d x1 y1 z1 unit ->
            case prop of
                Translate3d x2 y2 z2 _ ->
                    Translate3d (fn x1 x2) (fn y1 y2) (fn z1 z2) unit

                _ ->
                    prop

        TranslateX a unit ->
            case prop of
                TranslateX b _ ->
                    TranslateX (fn a b) unit

                _ ->
                    prop

        TranslateY a unit ->
            case prop of
                TranslateY b _ ->
                    TranslateY (fn a b) unit

                _ ->
                    prop

        Scale a ->
            case prop of
                Scale b ->
                    Scale (fn a b)

                _ ->
                    prop

        Scale3d x1 y1 z1 ->
            case prop of
                Scale3d x2 y2 z2 ->
                    Scale3d (fn x1 x2) (fn y1 y2) (fn z1 z2)

                _ ->
                    prop

        ScaleX a ->
            case prop of
                ScaleX b ->
                    ScaleX (fn a b)

                _ ->
                    prop

        ScaleY a ->
            case prop of
                ScaleY b ->
                    ScaleY (fn a b)

                _ ->
                    prop

        ScaleZ a ->
            case prop of
                ScaleZ b ->
                    ScaleZ (fn a b)

                _ ->
                    prop

        Rotate a unit ->
            case prop of
                Rotate b _ ->
                    Rotate (fn a b) unit

                _ ->
                    prop

        Rotate3d x1 y1 z1 a1 unit ->
            case prop of
                Rotate3d x2 y2 z2 a2 _ ->
                    Rotate3d (fn x1 x2) (fn y1 y2) (fn z1 z2) (fn a1 a2) unit

                _ ->
                    prop

        RotateX a unit ->
            case prop of
                RotateX b _ ->
                    RotateX (fn a b) unit

                _ ->
                    prop

        RotateY a unit ->
            case prop of
                RotateY b _ ->
                    RotateY (fn a b) unit

                _ ->
                    prop

        Skew x1 y1 unit ->
            case prop of
                Skew x2 y2 _ ->
                    Skew (fn x1 x2) (fn y1 y2) unit

                _ ->
                    prop

        SkewX a unit ->
            case prop of
                SkewX b _ ->
                    SkewX (fn a b) unit

                _ ->
                    prop

        SkewY a unit ->
            case prop of
                SkewY b _ ->
                    SkewY (fn a b) unit

                _ ->
                    prop

        Perspective a ->
            case prop of
                Perspective b ->
                    Perspective (fn a b)

                _ ->
                    prop

        Matrix a1 b1 c1 x1 y1 z1 ->
            case prop of
                Matrix a2 b2 c2 x2 y2 z2 ->
                    Matrix 
                        (fn a1 a2)
                        (fn b1 b2)
                        (fn c1 c2)
                        (fn x1 x2)
                        (fn y1 y2)
                        (fn z1 z2)

                _ ->
                    prop

        Matrix3d a1 b1 c1 d1 e1 f1 g1 h1 i1 j1 k1 l1 m1 n1 o1 p1 ->
            case prop of
                Matrix3d a2 b2 c2 d2 e2 f2 g2 h2 i2 j2 k2 l2 m2 n2 o2 p2 ->
                    Matrix3d (fn a1 a2)
                        (fn b1 b2)
                        (fn c1 c2)
                        (fn d1 d2)
                        (fn e1 e2)
                        (fn f1 f2)
                        (fn g1 g2)
                        (fn h1 h2)
                        (fn i1 i2)
                        (fn j1 j2)
                        (fn k1 k2)
                        (fn l1 l2)
                        (fn m1 m2)
                        (fn n1 n2)
                        (fn o1 o2)
                        (fn p1 p2)

                _ ->
                    prop

        X a -> 
            case prop of 
                X b -> X (fn a b)
                _ -> prop
        Y a -> 
            case prop of 
                Y b -> Y (fn a b)
                _ -> prop
        Cx a -> 
            case prop of 
                Cx b -> Cx (fn a b)
                _ -> prop
        Cy a -> 
            case prop of 
                Cy b -> Cy (fn a b)
                _ -> prop
        R a -> 
            case prop of 
                R b -> R (fn a b)
                _ -> prop
        Rx a -> 
            case prop of 
                Rx b -> Rx (fn a b)
                _ -> prop
        Ry a -> 
            case prop of 
                Ry b -> Ry (fn a b)
                _ -> prop
        D a -> 
            case prop of 
                D b -> D (fn a b)
                _ -> prop
        Points a -> 
            case prop of 
                Points b -> Points <| List.map2 fn a b
                _ -> prop



--Float -> Float -> Physics -> Physics


updateOver : (Float -> Float -> Physics -> Physics) -> Static -> Static -> Dynamic -> Dynamic
updateOver fn target prev prop =
            map3 
                fn
                (\targetColor prevColor currentDColor -> 
                    let
                        t = ElmColor.toRgb targetColor
                        p = ElmColor.toRgb prevColor
                    in 
                        case currentDColor of 
                            RGBA r1 g1 b1 a1 ->
                                RGBA 
                                    (fn (toFloat t.red) (toFloat p.red) r1)
                                    (fn (toFloat t.green) (toFloat p.green) g1)
                                    (fn (toFloat t.blue) (toFloat p.blue) b1)
                                    (fn t.alpha p.alpha a1)
                )
                target
                prev
                prop



{-|

This could be achieved more succinctly by doing 

    case (target, prev, prop) of
      (Opacity a, Opacity b, Opacity c) ->
        Opacity (fn a b c)

But there there are parser issues with the compiler.

This function was created by a python script.

-}
map3 : (a -> b -> c -> c) -> (colorA -> colorB -> colorC -> colorC) -> Property a colorA -> Property b colorB -> Property c colorC -> Property c colorC
map3 fn colorFn target prev prop =
    case target of
        Display _ ->
            prop

        Opacity a1 ->
            case prev of
                Opacity a2 ->
                    case prop of
                        Opacity a3 ->
                            Opacity (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        Height a1 unit1 ->
            case prev of
                Height a2 unit2 ->
                    case prop of
                        Height a3 unit3 ->
                            Height (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        Width a1 unit1 ->
            case prev of
                Width a2 unit2 ->
                    case prop of
                        Width a3 unit3 ->
                            Width (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        Left a1 unit1 ->
            case prev of
                Left a2 unit2 ->
                    case prop of
                        Left a3 unit3 ->
                            Left (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        Top a1 unit1 ->
            case prev of
                Top a2 unit2 ->
                    case prop of
                        Top a3 unit3 ->
                            Top (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        Right a1 unit1 ->
            case prev of
                Right a2 unit2 ->
                    case prop of
                        Right a3 unit3 ->
                            Right (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        Bottom a1 unit1 ->
            case prev of
                Bottom a2 unit2 ->
                    case prop of
                        Bottom a3 unit3 ->
                            Bottom (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        MaxHeight a1 unit1 ->
            case prev of
                MaxHeight a2 unit2 ->
                    case prop of
                        MaxHeight a3 unit3 ->
                            MaxHeight (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        MaxWidth a1 unit1 ->
            case prev of
                MaxWidth a2 unit2 ->
                    case prop of
                        MaxWidth a3 unit3 ->
                            MaxWidth (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        MinHeight a1 unit1 ->
            case prev of
                MinHeight a2 unit2 ->
                    case prop of
                        MinHeight a3 unit3 ->
                            MinHeight (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        MinWidth a1 unit1 ->
            case prev of
                MinWidth a2 unit2 ->
                    case prop of
                        MinWidth a3 unit3 ->
                            MinWidth (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        Padding a1 unit1 ->
            case prev of
                Padding a2 unit2 ->
                    case prop of
                        Padding a3 unit3 ->
                            Padding (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        PaddingLeft a1 unit1 ->
            case prev of
                PaddingLeft a2 unit2 ->
                    case prop of
                        PaddingLeft a3 unit3 ->
                            PaddingLeft (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        PaddingRight a1 unit1 ->
            case prev of
                PaddingRight a2 unit2 ->
                    case prop of
                        PaddingRight a3 unit3 ->
                            PaddingRight (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        PaddingTop a1 unit1 ->
            case prev of
                PaddingTop a2 unit2 ->
                    case prop of
                        PaddingTop a3 unit3 ->
                            PaddingTop (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        PaddingBottom a1 unit1 ->
            case prev of
                PaddingBottom a2 unit2 ->
                    case prop of
                        PaddingBottom a3 unit3 ->
                            PaddingBottom (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        Margin a1 unit1 ->
            case prev of
                Margin a2 unit2 ->
                    case prop of
                        Margin a3 unit3 ->
                            Margin (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        MarginLeft a1 unit1 ->
            case prev of
                MarginLeft a2 unit2 ->
                    case prop of
                        MarginLeft a3 unit3 ->
                            MarginLeft (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        MarginRight a1 unit1 ->
            case prev of
                MarginRight a2 unit2 ->
                    case prop of
                        MarginRight a3 unit3 ->
                            MarginRight (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        MarginTop a1 unit1 ->
            case prev of
                MarginTop a2 unit2 ->
                    case prop of
                        MarginTop a3 unit3 ->
                            MarginTop (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        MarginBottom a1 unit1 ->
            case prev of
                MarginBottom a2 unit2 ->
                    case prop of
                        MarginBottom a3 unit3 ->
                            MarginBottom (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        BorderWidth a1 unit1 ->
            case prev of
                BorderWidth a2 unit2 ->
                    case prop of
                        BorderWidth a3 unit3 ->
                            BorderWidth (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        BorderRadius a1 unit1 ->
            case prev of
                BorderRadius a2 unit2 ->
                    case prop of
                        BorderRadius a3 unit3 ->
                            BorderRadius (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        BorderTopLeftRadius a1 unit1 ->
            case prev of
                BorderTopLeftRadius a2 unit2 ->
                    case prop of
                        BorderTopLeftRadius a3 unit3 ->
                            BorderTopLeftRadius (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        BorderTopRightRadius a1 unit1 ->
            case prev of
                BorderTopRightRadius a2 unit2 ->
                    case prop of
                        BorderTopRightRadius a3 unit3 ->
                            BorderTopRightRadius (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        BorderBottomLeftRadius a1 unit1 ->
            case prev of
                BorderBottomLeftRadius a2 unit2 ->
                    case prop of
                        BorderBottomLeftRadius a3 unit3 ->
                            BorderBottomLeftRadius (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        BorderBottomRightRadius a1 unit1 ->
            case prev of
                BorderBottomRightRadius a2 unit2 ->
                    case prop of
                        BorderBottomRightRadius a3 unit3 ->
                            BorderBottomRightRadius (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        LetterSpacing a1 unit1 ->
            case prev of
                LetterSpacing a2 unit2 ->
                    case prop of
                        LetterSpacing a3 unit3 ->
                            LetterSpacing (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        LineHeight a1 unit1 ->
            case prev of
                LineHeight a2 unit2 ->
                    case prop of
                        LineHeight a3 unit3 ->
                            LineHeight (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        BackgroundPosition a1 b1 unit1 ->
            case prev of
                BackgroundPosition a2 b2 unit2 ->
                    case prop of
                        BackgroundPosition a3 b3 unit3 ->
                            BackgroundPosition (fn a1 a2 a3) (fn b1 b2 b3) unit1
                        _ -> prop

                _ -> prop

        Color color ->
            case prev of
                Color color2 ->
                    case prop of
                        Color color3 ->
                            Color <| colorFn color color2 color3
                        _ -> prop

                _ -> prop

        BackgroundColor color ->
            case prev of
                BackgroundColor color2 ->
                    case prop of
                        BackgroundColor color3 ->
                            BackgroundColor <| colorFn color color2 color3
                        _ -> prop

                _ -> prop

        BorderColor color ->
            case prev of
                BorderColor color2 ->
                    case prop of
                        BorderColor color3 ->
                            BorderColor <| colorFn color color2 color3
                        _ -> prop

                _ -> prop

        TransformOrigin a1 b1 c1 unit1 ->
            case prev of
                TransformOrigin a2 b2 c2 unit2 ->
                    case prop of
                        TransformOrigin a3 b3 c3 unit3 ->
                            TransformOrigin (fn a1 a2 a3) (fn b1 b2 b3) (fn c1 c2 c3) unit1
                        _ -> prop

                _ -> prop

        Matrix a1 b1 c1 d1 e1 f1 ->
            case prev of
                Matrix a2 b2 c2 d2 e2 f2 ->
                    case prop of
                        Matrix a3 b3 c3 d3 e3 f3 ->
                            Matrix (fn a1 a2 a3) (fn b1 b2 b3) (fn c1 c2 c3) (fn d1 d2 d3) (fn e1 e2 e3) (fn f1 f2 f3)
                        _ -> prop

                _ -> prop

        Matrix3d a1 b1 c1 d1 e1 f1 g1 h1 i1 j1 k1 l1 m1 n1 o1 p1 ->
            case prev of
                Matrix3d a2 b2 c2 d2 e2 f2 g2 h2 i2 j2 k2 l2 m2 n2 o2 p2 ->
                    case prop of
                        Matrix3d a3 b3 c3 d3 e3 f3 g3 h3 i3 j3 k3 l3 m3 n3 o3 p3 ->
                            Matrix3d (fn a1 a2 a3) (fn b1 b2 b3) (fn c1 c2 c3) (fn d1 d2 d3) (fn e1 e2 e3) (fn f1 f2 f3) (fn g1 g2 g3) (fn h1 h2 h3) (fn i1 i2 i3) (fn j1 j2 j3) (fn k1 k2 k3) (fn l1 l2 l3) (fn m1 m2 m3) (fn n1 n2 n3) (fn o1 o2 o3) (fn p1 p2 p3)
                        _ -> prop

                _ -> prop

        Translate a1 b1 unit1 ->
            case prev of
                Translate a2 b2 unit2 ->
                    case prop of
                        Translate a3 b3 unit3 ->
                            Translate (fn a1 a2 a3) (fn b1 b2 b3) unit1
                        _ -> prop

                _ -> prop

        Translate3d a1 b1 c1 unit1 ->
            case prev of
                Translate3d a2 b2 c2 unit2 ->
                    case prop of
                        Translate3d a3 b3 c3 unit3 ->
                            Translate3d (fn a1 a2 a3) (fn b1 b2 b3) (fn c1 c2 c3) unit1
                        _ -> prop

                _ -> prop

        TranslateX a1 unit1 ->
            case prev of
                TranslateX a2 unit2 ->
                    case prop of
                        TranslateX a3 unit3 ->
                            TranslateX (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        TranslateY a1 unit1 ->
            case prev of
                TranslateY a2 unit2 ->
                    case prop of
                        TranslateY a3 unit3 ->
                            TranslateY (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        Scale a1 ->
            case prev of
                Scale a2 ->
                    case prop of
                        Scale a3 ->
                            Scale (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        Scale3d a1 b1 c1 ->
            case prev of
                Scale3d a2 b2 c2 ->
                    case prop of
                        Scale3d a3 b3 c3 ->
                            Scale3d (fn a1 a2 a3) (fn b1 b2 b3) (fn c1 c2 c3)
                        _ -> prop

                _ -> prop

        ScaleX a1 ->
            case prev of
                ScaleX a2 ->
                    case prop of
                        ScaleX a3 ->
                            ScaleX (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        ScaleY a1 ->
            case prev of
                ScaleY a2 ->
                    case prop of
                        ScaleY a3 ->
                            ScaleY (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        ScaleZ a1 ->
            case prev of
                ScaleZ a2 ->
                    case prop of
                        ScaleZ a3 ->
                            ScaleZ (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        Rotate a1 unit1 ->
            case prev of
                Rotate a2 unit2 ->
                    case prop of
                        Rotate a3 unit3 ->
                            Rotate (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        Rotate3d a1 b1 c1 d1 unit1 ->
            case prev of
                Rotate3d a2 b2 c2 d2 unit2 ->
                    case prop of
                        Rotate3d a3 b3 c3 d3 unit3 ->
                            Rotate3d (fn a1 a2 a3) (fn b1 b2 b3) (fn c1 c2 c3) (fn d1 d2 d3) unit1
                        _ -> prop

                _ -> prop

        RotateX a1 unit1 ->
            case prev of
                RotateX a2 unit2 ->
                    case prop of
                        RotateX a3 unit3 ->
                            RotateX (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        RotateY a1 unit1 ->
            case prev of
                RotateY a2 unit2 ->
                    case prop of
                        RotateY a3 unit3 ->
                            RotateY (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        Skew a1 b1 unit1 ->
            case prev of
                Skew a2 b2 unit2 ->
                    case prop of
                        Skew a3 b3 unit3 ->
                            Skew (fn a1 a2 a3) (fn b1 b2 b3) unit1
                        _ -> prop

                _ -> prop

        SkewX a1 unit1 ->
            case prev of
                SkewX a2 unit2 ->
                    case prop of
                        SkewX a3 unit3 ->
                            SkewX (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        SkewY a1 unit1 ->
            case prev of
                SkewY a2 unit2 ->
                    case prop of
                        SkewY a3 unit3 ->
                            SkewY (fn a1 a2 a3) unit1
                        _ -> prop

                _ -> prop

        Perspective a1 ->
            case prev of
                Perspective a2 ->
                    case prop of
                        Perspective a3 ->
                            Perspective (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        X a1 ->
            case prev of
                X a2 ->
                    case prop of
                        X a3 ->
                            X (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        Y a1 ->
            case prev of
                Y a2 ->
                    case prop of
                        Y a3 ->
                            Y (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        Cx a1 ->
            case prev of
                Cx a2 ->
                    case prop of
                        Cx a3 ->
                            Cx (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        Cy a1 ->
            case prev of
                Cy a2 ->
                    case prop of
                        Cy a3 ->
                            Cy (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        R a1 ->
            case prev of
                R a2 ->
                    case prop of
                        R a3 ->
                            R (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        Rx a1 ->
            case prev of
                Rx a2 ->
                    case prop of
                        Rx a3 ->
                            Rx (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        Ry a1 ->
            case prev of
                Ry a2 ->
                    case prop of
                        Ry a3 ->
                            Ry (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        D a1 ->
            case prev of
                D a2 ->
                    case prop of
                        D a3 ->
                            D (fn a1 a2 a3)
                        _ -> prop

                _ -> prop

        Points props1 ->
            case prev of
                Points props2 ->
                    case prop of
                        Points props3 ->
                            Points <| List.map3 fn props1 props2 props3
                        _ -> prop

                _ -> prop
