//
//  AcceptButtonCell.swift
//  ePills
//
//  Created by Javier Calatrava on 24/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct PictureCell: View {
    @Binding var medicine: Medicine?
    @Binding var pictureMedicine: UIImage?
    @State var showSheet = false
    @State var showModal = false
    @State var sourceType: UIImagePickerController.SourceType = .photoLibrary

   // var action: () -> Void
    let horPadding: CGFloat = 15.0
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color(R.color.colorGray50Semi.name))
                        .padding(.horizontal, self.horPadding)
                    PrescriptionButtonView(iconName: "camera.on.rectangle", action: {
                        self.showSheet = true
                    })
                    if self.pictureMedicine != nil {
                        Image(uiImage: self.pictureMedicine ?? UIImage())
                            .resizable()
                            .aspectRatio(4 / 3, contentMode: .fit)
                            .padding(.horizontal, self.horPadding)
                            .onTapGesture {
                              self.showSheet = true
                            }
                    }
                }
            }.frame(height: geometry.size.height - (self.horPadding * 2) * 4 / 3)
                .actionSheet(isPresented: self.$showSheet, content: self.actionSheet)
                .sheet(isPresented: self.$showModal, content: {
                    ImagePickerView(sourceType: self.sourceType) { image in
                        self.pictureMedicine = image
                        self.showModal = false
                    }
                })
        }
    }

    private func actionSheet() -> ActionSheet {
        let actionSheet =
            ActionSheet(title: Text(R.string.localizable.prescription_form_interval_pict_origin.key.localized),
                        message: Text(R.string.localizable.prescription_form_interval_pict_origin_desc.key.localized),
                      buttons: [.default(Text(R.string.localizable.prescription_form_interval_camera.key.localized)) {
                               self.sourceType = .camera
                               self.showModal = true
                            },
                           .default(Text(R.string.localizable.prescription_form_interval_roll.key.localized)) {
                               self.sourceType = .photoLibrary
                               self.showModal = true
                            },
                           .cancel()
                      ])
        return actionSheet
    }

    init(medicine: Binding<Medicine?>, pictureMedicine: Binding<UIImage?>) {
        self._medicine = medicine
        self._pictureMedicine = pictureMedicine
    }
}

struct ActionButtonCell_Previews: PreviewProvider {
    static var previews: some View {
        AcceptButtonCell(medicine: .constant(nil), action: { })
    }
}
