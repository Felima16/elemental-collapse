import SwiftUI

struct HomeView: View {
    @State var viewModel = HomeViewModel()

    var body: some View {
        createBody()
    }

    private func createBody() -> some View {
        VStack {
            createTopBar()

            Spacer()

            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 160)


            Text("Elemental \n Collapse")
                .font(.custom("eras-itc", fixedSize: 36))

            VStack(spacing: 8) {
                Button {
                    viewModel.showPlayOptions.toggle()
                } label: {
                    HStack {
                        Image(systemName: "play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16)

                        Text("Play")
                            .font(.custom("Agbalumo-Regular", fixedSize: 24))
                    }
                }
                .buttonStyle(InitialButton(isSelected: $viewModel.showPlayOptions))

                if viewModel.showPlayOptions {
                    createSecondaryButtons()
                }

                Button {
                    viewModel.showPlayOptions.toggle()
                } label: {
                    Text("Options")
                        .font(.custom("Agbalumo-Regular", fixedSize: 24))
                }
                .buttonStyle(InitialButton(isSelected: .constant(false)))

                Button {
                    viewModel.showPlayOptions.toggle()
                } label: {
                    Text("Credits")
                        .font(.custom("Agbalumo-Regular", fixedSize: 24))
                }
                .buttonStyle(InitialButton(isSelected: .constant(false)))

            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .animation(.easeInOut, value: viewModel.showPlayOptions)
        .fullScreenCover(isPresented: $viewModel.showAvailablePlayers) {
            AvailablePlayersView(
                viewModel: .init(gameNetwork: NetworkManager(name: viewModel.name)),
                showAvailableView: $viewModel.showAvailablePlayers
            )
        }
        .alert(
            Text(viewModel.alertTitle),
            isPresented: $viewModel.showAlertEditName
        ) {
            Button("Cancel", role: .cancel) {
                viewModel.showAlertEditName = false
            }
            Button("OK") {
                viewModel.saveName()
            }

            TextField("name", text: $viewModel.name)
        }
    }

    private func createTopBar() -> some View {
        HStack {
            Button {
                viewModel.showAlertEditName = true
            } label: {
                Text(viewModel.name)
                    .foregroundStyle(.iconDomix)
                    .font(.title2)
                    .padding(.leading, 24)
            }

            Spacer()

            Button {

            } label: {
                Image(systemName: "speaker.slash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .padding(.trailing, 8)
                    .foregroundStyle(.iconDomix)
            }

            Image(systemName: "person.crop.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40)
                .clipShape(Circle())
                .padding(.trailing, 16)
        }
        .padding(.top, 16)
    }

    private func createSecondaryButtons() -> some View {
        VStack {
            Button {
//                gameManager.playTutorial()
            } label: {
                Text("Tutorial")
                    .font(.custom("Agbalumo-Regular", fixedSize: 16))
            }
            .buttonStyle(InitialButton(isSelected: .constant(false)))

            Button {
                viewModel.showAvailablePlayers = true
            } label: {
                Text("Connect")
                    .font(.custom("Agbalumo-Regular", fixedSize: 16))
            }
            .buttonStyle(InitialButton(isSelected: .constant(false)))
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    HomeView()
}
