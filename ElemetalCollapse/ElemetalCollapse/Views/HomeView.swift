import SwiftUI

struct HomeView: View {
    @State var showPlayOptions = false
    @State var showAvailablePlayers = false

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
                .frame(height: 200)


            Text("PEGADA DOMINO")
                .font(.title)
                .bold()

            VStack(spacing: 8) {
                Button {
                    showPlayOptions.toggle()
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
                .buttonStyle(InitialButton(isSelected: $showPlayOptions))

                if showPlayOptions {
                    createSecondaryButtons()
                }

                Button {
                    showPlayOptions.toggle()
                } label: {
                    Text("Options")
                        .font(.custom("Agbalumo-Regular", fixedSize: 24))
                }
                .buttonStyle(InitialButton(isSelected: .constant(false)))

                Button {
                    showPlayOptions.toggle()
                } label: {
                    Text("Credits")
                        .font(.custom("Agbalumo-Regular", fixedSize: 24))
                }
                .buttonStyle(InitialButton(isSelected: .constant(false)))

            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .animation(.easeInOut, value: showPlayOptions)
        .fullScreenCover(isPresented: $showAvailablePlayers) {
            AvailablePlayersView(
                viewModel: .init(gameNetwork: NetworkManager()),
                showAvailableView: $showAvailablePlayers
            )
        }
    }

    private func createTopBar() -> some View {
        HStack {
            Spacer()

            Button {

            } label: {
                Image(systemName: "speaker.slash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .padding(.trailing, 8)
                    .foregroundStyle(.whiteDomix)
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
                showAvailablePlayers = true
            } label: {
                Text("Connect")
                    .font(.custom("Agbalumo-Regular", fixedSize: 16))
            }
            .buttonStyle(InitialButton(isSelected: .constant(false)))
//            .disabled(gameManager.matchAvailable)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    HomeView()
}
