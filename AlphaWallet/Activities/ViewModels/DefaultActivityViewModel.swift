// Copyright © 2020 Stormbird PTE. LTD.

import UIKit
import BigInt

struct DefaultActivityViewModel {
    private var server: RPCServer {
        activity.server
    }

    private var cardAttributes: [AttributeId: AssetInternalValue] {
        activity.values.card
    }

    let activity: Activity

    var contentsBackgroundColor: UIColor {
        .white
    }

    var backgroundColor: UIColor {
        Colors.appBackground
    }

    var amount: NSAttributedString {
        let sign: String
        switch activity.nativeViewType {
        case .erc20Sent, .nativeCryptoSent:
            sign = "- "
        case .erc20Received, .nativeCryptoReceived:
            sign = "+ "
        case .erc20OwnerApproved, .erc20ApprovalObtained, .erc721OwnerApproved, .erc721ApprovalObtained, .erc721Sent, .erc721Received:
            sign = ""
        case .none:
            sign = ""
        }

        let string: String
        switch activity.nativeViewType {
        case .erc20Sent, .erc20Received, .nativeCryptoSent, .nativeCryptoReceived:
            if let value = cardAttributes["amount"]?.uintValue {
                string = stringFromFungibleAmount(sign: sign, amount: value)
            } else {
                string = ""
            }
        case .erc20OwnerApproved, .erc20ApprovalObtained:
            if let value = cardAttributes["amount"]?.uintValue {
                if doesApprovedAmountLookReallyBig(value, decimals: activity.tokenObject.decimals) {
                    string = R.string.localizable.activityApproveAmountAll(activity.tokenObject.symbol)
                } else {
                    string = stringFromFungibleAmount(sign: sign, amount: value)
                }
            } else {
                string = ""
            }
        case .erc721Sent, .erc721Received, .erc721OwnerApproved, .erc721ApprovalObtained:
            if let value = cardAttributes["tokenId"]?.uintValue {
                string = "\(value)"
            } else {
                string = ""
            }
        case .none:
            string = ""
        }

        switch activity.state {
        case .pending:
            return NSAttributedString(string: string, attributes: [.font: Fonts.regular(size: 28), .foregroundColor: R.color.black()!])
        case .completed:
            return NSAttributedString(string: string, attributes: [.font: Fonts.regular(size: 28), .foregroundColor: R.color.black()!])
        case .failed:
            return NSAttributedString(string: string, attributes: [.font: Fonts.regular(size: 28), .foregroundColor: R.color.silver()!, .strikethroughStyle: NSUnderlineStyle.single.rawValue])
        }
    }

    private func stringFromFungibleAmount(sign: String, amount: BigUInt) -> String {
        let formatter = EtherNumberFormatter.short
        let value = formatter.string(from: BigInt(amount), decimals: activity.tokenObject.decimals)
        return "\(sign)\(value) \(activity.tokenObject.symbol)"
    }

    private func doesApprovedAmountLookReallyBig(_ amount: BigUInt, decimals: Int) -> Bool {
        let empiricallyBigLimit: Double = 90_000_000
        return Double(amount) / pow(10, activity.tokenObject.decimals).doubleValue > empiricallyBigLimit
    }
}
