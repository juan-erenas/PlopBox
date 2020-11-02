

import Foundation

public struct PlopBoxProducts {
  
  public static let SwiftShopping = "com.buffthumbgames.plopbox.removeads"
  
  private static let productIdentifiers: Set<ProductIdentifier> = [PlopBoxProducts.SwiftShopping]

  public static let store = IAPHelper(productIds: PlopBoxProducts.productIdentifiers)
}
 
