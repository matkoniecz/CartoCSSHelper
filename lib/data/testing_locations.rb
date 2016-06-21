module CartoCSSHelper
  def self.get_list_of_testing_locations
    return [
      [50.1, 19.9], # Krakow
      [53.2, -1.8], # rural uk
      [36.1, 140.7], # Japan
      [54.8, 31.7], # Russia
      [21.3, 39.5], # Mecca
      [41.4, 44.5], # Georgia
      [51.5, -0.1], # London
      # TODO: solve problems with response too big to store in memory
      # [52.09, 5.11], #Utrecht

      # http://overpass-turbo.eu/s/ar4
      # capital locations
      [-41.2887639, 174.7772239],
      [37.9841493, 23.7279843],
      [46.0498650, 14.5068921],
      [55.6867243, 12.5700724],
      [28.6138967, 77.2159562],
      [33.6945756, 73.0643744],
      [48.2083537, 16.3725042],
      # [48.8565056, 2.3521334], TODO: solve problems with rest-client crashing and blabbing about negative integers
      [46.9482713, 7.4514512],
      [45.4210328, -75.6900219],
      [59.9132694, 10.7391112],
      [33.3024248, 44.3787992],
      [40.4167047, -3.7035825],
      [-35.2819367, 149.1288940],
      [34.5197058, 69.1624302],
      [39.9059093, 116.3913489],
      [-25.7250000, 28.1847222],
      [39.9220794, 32.8537580],
      [59.3251172, 18.0710935],
      [35.6861720, 51.4223519],
      [50.4501071, 30.5240501],
      [53.9023386, 27.5619023],
      [23.1379911, -82.3658562],
      [56.9493977, 24.1051846],
      [-4.3217055, 15.3125974],
      [54.6843135, 25.2853984],
      [55.1598408, 61.4025547],
      [42.8766343, 74.6070116],
      [41.3123363, 69.2787079],
      [38.5762757, 68.7863940],
      [47.9184676, 106.9177016],
      [51.1282789, 71.4305478],
      [13.5248339, 2.1098226],
      [-8.8271656, 13.2436665],
      [12.6500083, -8.0000014],
      [36.8001077, 10.1847938],
      [6.3280343, -10.7977882],
      [4.3909085, 18.5505422],
      [-15.4166967, 28.2813812],
      [12.3681481, -1.5270853],
      [12.1191543, 15.0502758],
      [14.6930042, -17.4470260],
      [8.4790017, -13.2680158],
      [9.5171253, -13.6999235],
      [0.3900022, 9.4540009],
      [9.0107934, 38.7612525],
      [5.5600141, -0.2057437],
      [-25.9662133, 32.5674498],
      [11.5936649, 43.1472403],
      [-1.2832533, 36.8172449],
      [-18.9100122, 47.5255809],
      [15.5933247, 32.5356502],
      [14.9160169, -23.5096132],
      [62.0120000, -6.7680000],
      [31.7774287, 35.2247239],
      [59.4372155, 24.7453688],
      [-29.3100536, 27.4782219],
      [-24.6585857, 25.9084905],
      [39.0196396, 125.7525841],
      [36.5658725, 53.0585690],
      [-33.9289049, 18.4172485],
      [-22.5744184, 17.0791233],
      [-15.7934036, -47.8823172],
      [2.0427779, 45.3385636],
      [26.2235041, 50.5822436],
      [-33.4377968, -70.6504451],
      [12.5268736, -70.0356845],
      [12.1091242, -68.9316546],
      [12.1471741, -68.2740783],
      [6.9342870, 79.8532704],
      [49.6112768, 6.1297990],
      [18.4652988, -66.1166657],
      [17.9712148, -76.7928128],
      [-0.2201687, -78.5120913],
      [42.5069391, 1.5212467],
      [-12.0458271, -77.0304845],
      [-1.9508511, 30.0615075],
      [44.8178787, 20.4568089],
      [-3.3638125, 29.3675028],
      [27.7087963, 85.3202438],
      [41.8933439, 12.4830718],
      [21.0292095, 105.8524700],
      [-34.6128690, -58.4459789],
      [47.4983815, 19.0404707],
      [-6.1791181, 35.7468174],
      [43.4930746, 43.6193570],
      [44.4361390, 26.1027436],
      [4.8472017, 31.5951655],
      [-17.7414972, 168.3150163],
      [25.0783456, -77.3383331],
      [17.9640988, 102.6133707],
      [42.4415238, 19.2621081],
      [47.0122737, 28.8605936],
      [40.1776121, 44.5125849],
      [38.8949549, -77.0366456],
      [41.6509502, 41.6360085],
      [41.9960424, 21.4316707],
      [12.1461244, -86.2737170],
      [17.2960919, -62.7223010],
      [9.9325612, -84.0795739],
      [13.6977587, -89.1930100],
      [14.5906216, 120.9799696],
      [23.5997857, 58.5451305],
      [-9.4797487, 147.1503589],
      [15.2984622, -61.3875049],
      [52.5170365, 13.3888599],
      [50.2796448, 57.2124606],
      [-20.1637281, 57.5045331],
      [-26.3257447, 31.1446630],
      [39.5089040, 54.3631062],
      [12.0535331, -61.7518050],
      [13.1561653, -61.2248777],
      [14.0095719, -60.9903195],
      [13.1018264, -59.6188480],
      [18.0794011, -15.9780393],
      [13.4553495, -16.5756457],
      [-25.2960638, -57.6311446],
      [11.8613244, -15.5830554],
      [15.3421010, 44.2005197],
      [24.4747961, 54.3705762],
      [-8.5536809, 125.5784093],
      [15.3389974, 38.9326725],
      [35.6823815, 139.7530053],
      [18.0250713, -63.0483073],
      [38.7130574, -9.1380056],
      [-21.2074736, -159.7708145],
      [52.3710088, 4.9001115],
      [-7.7441461, 113.2158401],
      [30.0488185, 31.2436663],
      [48.4814020, 135.0769400],
      [18.3411365, -64.9327890],
      [43.9363996, 12.4466991],
      [5.8216198, -55.1771974],
      [17.2502830, -88.7694263],
      [-17.8317726, 31.0456859],
      [18.5473270, -72.3395928],
      [33.8959203, 35.4784300],
      [3.7528278, 8.7800610],
      [6.8025766, -58.1628612],
      [0.3389242, 6.7313031],
      [-34.9059039, -56.1913569],
      [21.4607723, -71.1399956],
      [34.0223602, -6.8390357],
      [14.0931919, -87.2012631],
      [-19.0478620, -65.2596023],
      [18.4801972, -69.9421110],
      [24.6319692, 46.7150648],
      [19.7540045, 96.1344976],
      [6.8091068, -5.2732628],
      [3.8689867, 11.5213344],
      [-11.6931255, 43.2543044],
      [7.0909924, 171.3816354],
      [-13.8343691, -171.7692793],
      [41.9034912, 12.4528349],
      [17.1184569, -61.8448509],
      [52.2319237, 21.0067265],
      [-4.2694407, 15.2712256],
      [-19.0534159, -169.9191992],
      [14.6417889, -90.5132239],
      [17.1393977, -62.6216154],
      [48.1535383, 17.1096711],
      [1.2904527, 103.8520380],
      [29.3797091, 47.9735629],
      [11.5682710, 104.9224426],
      [-8.5211767, 179.1976747],
      [4.5980478, -74.0760867],
      [16.7053047, -62.2130447],
      [1.3497964, 173.0277185],
      [6.9207440, 158.1627143],
      [7.4966382, 134.6349089],
      [0.3177137, 32.5813539],
      [19.2869856, -81.3717001],
      [-9.4312971, 159.9552773],
      [-2.2100307, 113.9267408],
      [64.1750290, -51.7355386],
      [-21.1343401, -175.2018085],
      [33.5130695, 36.3095814],
      [25.0375167, 121.5637000],
      [8.9500000, 38.7666700],
      [8.9707433, -79.5344539],
      [60.1666277, 24.9435079],
      [27.4730932, 89.6296788],
      [35.8987546, 14.5134889],
      [45.8131545, 15.9770298],
      [50.0874401, 14.4212556],
      [41.6934350, 44.8014979],
      [13.7529438, 100.4941219],
      [50.8465565, 4.3516970],
      [31.9515694, 35.9239625],
      [6.4990718, 2.6253361],
      [25.2856329, 51.5264162],
      [55.7516335, 37.6187042],
      [4.8895453, 114.9417574],
      [32.8966720, 13.1777923],
      [42.6977211, 23.3225964],
      [43.7311966, 7.4196400],
      [37.9396678, 58.3874263],
      [11.1852893, -60.7350240],
      [41.3279457, 19.8185323],
      [3.1570976, 101.7009528],
      [35.1739302, 33.3647260],
      [37.5666791, 126.9782914],
      [47.1392862, 9.5227962],
      [-14.2753717, -170.7048530],
      [15.1759138, 145.7432916],
      [18.2108070, -63.0535045],
      [26.3544056, -9.5741765],
      [43.8515421, 18.3886246],
      [-2.9888297, 104.7568570],
      [64.1459810, -21.9422367],
      [40.3754289, 49.8328549],
      [6.1258594, 1.2248504],
      [54.1497740, -4.4779021],
      [-18.1415884, 178.4421662],
      [46.8516039, 29.6349435],
      [38.3716205, 26.1342054],
      [49.1855551, -2.1098279],
      [10.6572142, -61.5180297],
      [-1.6141280, 103.5796708],
      [42.6636827, 21.1639418],
      [-13.9734560, 33.7878122],
      [43.7311424, 7.4197576],
      [6.9031663, 79.9091644],
      [-8.5202604, 179.1974823],
      [4.1779879, 73.5107387],
      [53.3497645, -6.2602732],
    ]
  end
end
