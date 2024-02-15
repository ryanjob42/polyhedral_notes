package installTest

import alpha.model.AlphaModelLoader
import alpha.model.util.Show

class InstallTestCompile {
    def static void main(String[] args) {
        val root = AlphaModelLoader.loadModel("resources/Install Test.alpha")
        println(Show.print(root))
    }
}