/**
* Copyright 2009 Google Inc. 
* Licensed under the Apache License, Version 2.0:
*  http://www.apache.org/licenses/LICENSE-2.0
*/

package com.google.maps.extras.gradients.test {
  import com.google.maps.extras.gradients.test.GradientControlTest;
  import flexunit.framework.TestSuite;

  /** 
  * Test suite for the GradientControl-related classes.
  *   
  * @author Simon Ilyushchenko
  */  

  public class AllTests {

    /**
    * Collect all test classes and return them.
    */
    public static function getAllTests():TestSuite {
      var testSuite:TestSuite = new TestSuite();
      testSuite.addTestSuite(GradientControlTest);
      return testSuite;
    }
  }
}
