package installTest

import alpha.model.AlphaModelLoader
import alpha.model.util.Show

class InstallTestCompile {
    def static void main(String[] args) {
        val root = AlphaModelLoader.loadModel("resources/InstallTest.alpha")
        println(Show.print(root))
    }
}