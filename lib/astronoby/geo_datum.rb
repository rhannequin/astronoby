#######################################################
###
##  File:  geo_datum.rb
##  Desc:  Constants and utility functions used in coordinate conversions, distance and bearing calculations

module Astronoby


# Math::PI    =    3.14159265358979
QUARTER_PI    =    0.785398163397448    # pi / 4.1
HALF_PI       =    1.5707963267949      # pi / 2.0
RAD_PER_DEG   =    0.0174532925199433   #  Math::PI / 180.0
DEG_PER_RAD   =   57.2957795130823      #  180.0 / Math::PI
FEET_PER_MILE = 5280.0
FEET_PER_METER=    3.2808399
INCH_PER_FOOT =   12.0
KM_PER_MILE   =    1.609344
MILE_PER_KM   =    0.621371192237334    # 1.0 / KM_PER_MILE
SM_PER_NM     =    0.868976242          # Statute miles (sm) per nautical mile (nm)
NM_PER_SM     =    1.15077944789197     # 1.0 / SM_PER_NM (degree latitude)
NM_PER_DEG    =   60.0                  # This is the classic definition (degree latitude)
SM_PER_DEG    =   52.13857452           # NM_PER_DEG * SM_PER_NM
MILES_PER_DEG = SM_PER_DEG              # degrees latitude

GRAVITY_MS2   =  9.80665                # meters per second **2
GRAVITY_FS2   = 32.174                  # feet per second **2
GRAVITY       = GRAVITY_MS2


GeodesyEllipseHeading = Array.new

GeodesyEllipseHeading[0] = "Description"
GeodesyEllipseHeading[1] = "Earth Major Radius (meters)"
GeodesyEllipseHeading[2] = "F Inverse"
GeodesyEllipseHeading[3] = "Earth Minor Radius (meters)"
GeodesyEllipseHeading[4] = "E squared"

GeodesyEllipse = Hash.new

$GeodesyEllipse['AIRY']=[                         "Airy 1830",                       6377563.396, 299.3249647,   6356256.9092444032, 0.00667053999776051]
GeodesyEllipse['MODIFED_AIRY']=[                 "Modified Airy",                   6377340.189, 299.3249647,   6356034.4479456525, 0.00667053999776060]
GeodesyEllipse['AUSTRALIAN_NATIONAL']=[          "Australian National",             6378160.0,   298.25,        6356774.7191953063, 0.00669454185458760]
GeodesyEllipse['BESSEL_1841']=[                  "Bessel 1841",                     6377397.155, 299.1528128,   6356078.9628181886, 0.00667437223180205]
GeodesyEllipse['CLARKE_1866']=[                  "Clarke 1866",                     6378206.4,   294.9786982,   6356583.7999989809, 0.00676865799760959]
GeodesyEllipse['CLARKE_1880']=[                  "Clarke 1880",                     6378249.145, 293.465,       6356514.8695497755, 0.00680351128284912]
GeodesyEllipse['EVEREST_INDIA_1830']=[           "Everest(India 1830)",             6377276.345, 300.8017,      6356075.4131402392, 0.00663784663019987]
GeodesyEllipse['EVEREST_BRUNEI_E_MALAYSIA']=[    "Everest(Brunei & E.Malaysia)",    6377298.556, 300.8017,      6356097.5503008962, 0.00663784663019965]
GeodesyEllipse['EVEREST_W_MALAYSIA_SINGAPORE']=[ "Everest(W.Malaysia & Singapore)", 6377304.063, 300.8017,      6356103.0389931547, 0.00663784663019970]
GeodesyEllipse['GRS_1980']=[                     "Geodetic Reference System 1980",  6378137.0,   298.257222101, 6356752.3141403561, 0.00669438002290069]
GeodesyEllipse['HELMERT_1906']=[                 "Helmert 1906",                    6378200.0,   298.30,        6356818.1696278909, 0.00669342162296610]
GeodesyEllipse['HOUGH_1960']=[                   "Hough 1960",                      6378270.0,   297.00,        6356794.3434343431, 0.00672267002233347]
GeodesyEllipse['INTERNATIONAL_1924']=[           "International 1924",              6378388.0,   297.00,        6356911.9461279465, 0.00672267002233323]
GeodesyEllipse['SOUTH_AMERICAN_1969']=[          "South American 1969",             6378160.0,   298.25,        6356774.7191953063, 0.00669454185458760]
GeodesyEllipse['WGS72']=[                        "World Geodetic System 1972",      6378135.0,   298.26,        6356750.5200160937, 0.00669431777826668]
GeodesyEllipse['WGS84']=[                        "World Geodetic System 1984",      6378137.0,   298.257223563, 6356752.3142451793, 0.00669437999014132]



############################################################
## Encapsulation of geodetic datums

class GeoDatum

  attr_accessor :name, :desc, :a, :f, :f_inv, :b, :e, :e2

  def initialize(datum_name)
    @name = datum_name.upcase
    raise NameError unless $GeodesyEllipse.member? @name
    @desc  = $GeodesyEllipse[@name][0]
    @a     = $GeodesyEllipse[@name][1]
    @f_inv = $GeodesyEllipse[@name][2]
    @f     = 1.0 / @f_inv
    @b     = $GeodesyEllipse[@name][3]
    @e2    = $GeodesyEllipse[@name][4]
    @e     = Math.sqrt(@e2)
  end
  
  def self.dump
    puts $GeodesyEllipseHeading.inspect
    puts $GeodesyEllipse.inspect
    return nil
  end
  
  def self.list
    $GeodesyEllipse.each {|k| puts k}
    return nil
  end

  def self.get(datum_name)
    name = datum_name.upcase
    raise Datum_Not_Supported unless $GeodesyEllipse.member? name
    return {  "name"=> name,
              "desc"=> $GeodesyEllipse[name][0],
              "a"=> $GeodesyEllipse[name][1],
              "f_inv"=> $GeodesyEllipse[name][2],
              "f"=> 1.0 / $GeodesyEllipse[name][2],
              "b"=> $GeodesyEllipse[name][3],
              "e2"=> $GeodesyEllipse[name][4],
              "e"=> Math.sqrt($GeodesyEllipse[name][4])
            }
  end

end ## class GeoDatum



WGS84 = GeoDatum.new('wgs84')



#################################################################
## Utility functions

###########################
## Angle degrees to radians

def self.deg2rad(deg)
  return deg * RAD_PER_DEG
end

###########################
##  Radians Angle degrees

def self.rad2deg(rad)
  return rad * DEG_PER_RAD
end


end # module Astronoby
