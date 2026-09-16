//
//  EditProfileSheet.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

public struct EditProfileSheet: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(ProfileViewModel.self) private var profileViewModel

    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var birthday: String = ""
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?

    public init() {}

    public var body: some View {
        VStack {
            navigationBar(
                onBack: { router.dismissTopSheet() },
                onLogout: { router.dismissAllSheets() },
                onDeleteProfile: { router.dismissAllSheets() }
            )

            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    formFields()

                    if let error = errorMessage {
                        errorText(error)
                    }

                    saveButton(isLoading: isSaving) {
                        saveChanges()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            populateFields()
        }
    }
}

extension EditProfileSheet {
    private var userInitial: String {
        if let first = name.first {
            return String(first).uppercased()
        }
        return "А"
    }

    private func navigationBar(
        onBack: @escaping () -> Void,
        onLogout: @escaping () -> Void,
        onDeleteProfile: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .top) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DSColors.textPrimary)
            }

            Spacer()

            Circle()
                .fill(DSColors.lightGradient)
                .frame(width: 80, height: 80)
                .overlay(
                    Text(userInitial)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(DSColors.textPrimary)
                )

            Spacer()

            Menu {
                Button(action: onLogout) {
                    Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                }

                Button(role: .destructive, action: onDeleteProfile) {
                    Label("Удалить профиль", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DSColors.textPrimary)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal)
        .padding(.top, 14)
        .padding(.bottom)
    }

    @ViewBuilder
    private func formFields() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            DSFormField("Имя", text: $name, topPadding: 12)
            Divider()
                .padding(.vertical, 8)

            DSFormField(
                "Телефон",
                placeholder: "+7 900 000-00-00",
                text: $phone,
                isDisabled: true,
                showsLock: true,
                topPadding: 12
            )
            Divider()
                .padding(.vertical, 8)

            DSFormField(
                "День рождения",
                placeholder: "18.07.1992",
                text: $birthday,
                topPadding: 12
            )
        }
        .padding(.horizontal, 4)
    }

    private func errorText(_ error: String) -> some View {
        Text(error)
            .font(DSTypography.caption)
            .foregroundStyle(.red)
    }

    private func saveButton(isLoading: Bool, action: @escaping () -> Void) -> some View {
        DSButton(
            action: action,
            buttonTitle: "Сохранить изменения",
            style: .accent,
            isLoading: isLoading
        )
        .padding(.top, 16)
    }

    private func populateFields() {
        if let p = profileViewModel.profile {
            name = p.name
            phone = p.phone
            birthday = p.birthday
        }
    }

    private func saveChanges() {
        guard !isSaving else { return }
        errorMessage = nil

        let draft = ProfileDraft(
            name: name,
            birthday: birthday.isEmpty ? "18.07.1992" : birthday,
            imageURI: profileViewModel.profile?.imageURL?.absoluteString ?? "https://eat-and-pay.t02.ru/uploads/eats-jxl/bread.jxl"
        )

        guard draft.isValid else {
            errorMessage = "Проверьте корректность формата даты (ДД.ММ.ГГГГ)"
            return
        }

        isSaving = true
        Task {
            let success = await profileViewModel.save(draft)
            isSaving = false
            if success {
                router.dismissTopSheet()
            } else {
                errorMessage = profileViewModel.saveError ?? "Ошибка сохранения"
            }
        }
    }
}
