package features;

import com.intuit.karate.junit5.Karate;

public class TestRunners {

	@Karate.Test
    Karate runAllApiTests() {
        return Karate.run(
                "getbrandinginformation",
                "getlistavailablerooms",
                "bookroom"
        ).relativeTo(getClass());
	}
}
