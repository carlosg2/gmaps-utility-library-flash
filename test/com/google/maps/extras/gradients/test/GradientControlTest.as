/**
* Copyright 2009 Google Inc. 
* Licensed under the Apache License, Version 2.0:
*  http://www.apache.org/licenses/LICENSE-2.0
*/

package com.google.maps.extras.gradients.test {
  import flash.errors.IllegalOperationError;
  import flexunit.framework.TestCase;

  import com.google.maps.Color;
  import com.google.maps.extras.gradients.GradientControl;
  import com.google.maps.extras.gradients.GradientControl;
  import com.google.maps.extras.gradients.GradientRule;
  import com.google.maps.extras.gradients.GradientRuleList;
  import com.google.maps.extras.gradients.GradientUtil;
  import com.google.maps.extras.gradients.ValueColorGradient;

  /** 
  * Test collection for GradientControl and related classes
  *   
  * @author Simon Ilyushchenko
  */  

  public class GradientControlTest extends flexunit.framework.TestCase {

    public function testLinearScale(): void {
      var src:Object = { 'min': 0, 'max': 10 };
      var dst:Object = { 'min': 100, 'max': 200 };
      assertEquals(140, GradientUtil.linearScale(src, dst, 4));
      assertEquals(145, GradientUtil.linearScale(src, dst, 4.5));
      assertEquals(150, GradientUtil.linearScale(src, dst, 4, 2));

      // Dst limits are never exceeded.
      assertEquals(200, GradientUtil.linearScale(src, dst, 1000));
      assertEquals(100, GradientUtil.linearScale(src, dst, -50));

      // Zero src or dst interval lengts are ok.
      src = { 'min': 0, 'max': 10 };
      dst = { 'min': -100, 'max': -200 };
      assertEquals(-120, GradientUtil.linearScale(src, dst, 2));

      src = { 'min': 0, 'max': 0 };
      dst = { 'min': 0, 'max': 0 };
      assertEquals(0, GradientUtil.linearScale(src, dst, 0));

      src = { 'min': 5, 'max': 5 };
      dst = { 'min': -10, 'max': 10 };
      assertEquals(-10, GradientUtil.linearScale(src, dst, 20));

      src = { 'min': 5, 'max': 15 };
      dst = { 'min': 10, 'max': 10 };
      assertEquals(10, GradientUtil.linearScale(src, dst, 11));
    }

    // TODO(simonf): what, no assertRaises? 
    // Add checks for absent min/max keys in src and dst.
    public function testLinearScaleError(): void {
      var src:Object = { 'min': 0, 'max': 10 };
      var dst:Object = { 'min': 100, 'max': 200 };
      try 
      {   
        GradientUtil.linearScale(src, dst, 4, -2);

        }   
        catch ( e : IllegalOperationError )
        {   
          return;
        }   
       assertFalse ( "Should have thrown an IllegalOperationError" );
    }   
    

    public function testGradientColorForValue():void {
      var g:ValueColorGradient = new ValueColorGradient();
      // 0 and 100 percent are defaults
      g.minColor = Color.RED;
      g.maxColor = Color.YELLOW;
      g.minValue = 10;
      g.maxValue = 20;
      assertEquals(
          0xff8000, 
          g.colorForValue(15));
    }

    private function verifyGradients(
        gc:GradientControl, valuesAndColors:Array):void {
      for each(var dict:Object in valuesAndColors) {
        assertEquals(dict['c'], gc.colorForValue(dict['v']));
      }
    }

    public function testTwoColorGradient():void {
      var values:Array = [20, 10, 13];

      var gradientControl:GradientControl = (
          GradientRuleList.twoColorGradientControl(
              Color.RED, Color.YELLOW, values)
      )

      var expected:Array = [
        {'v': 15, 'c': 0xff8000}]
      verifyGradients(gradientControl, expected);

      var xml:XML = 
        <gradientRuleList>
          <gradientRule>
            <gradient>
              <minColor>0xff0000</minColor>
              <maxColor>0xffff00</maxColor>
            </gradient>
          </gradientRule>
        </gradientRuleList>;

      var ruleList:GradientRuleList = GradientRuleList.fromXML(xml);
      var gc2:GradientControl = ruleList.applyGradientToValueList(values);
      verifyGradients(gc2, expected);
    }

    public function testTwoColorGradientOneValue():void {
      var values:Array = [10];

      var gradientControl:GradientControl = (
          GradientRuleList.twoColorGradientControl(
              Color.RED, Color.YELLOW, values)
      )

      var expected:Array = [
        {'v': 15, 'c': Color.RED}]
      verifyGradients(gradientControl, expected);
    }

    public function testThreeColorGradient():void {
      var values:Array = [131.7, 170, 110];

      var gradientControl:GradientControl = (
          GradientRuleList.threeColorGradientControl(
              Color.RED, Color.YELLOW, Color.GREEN, values)
      )
      // Test values at the middle of each half (at 25% and 75% of the total).
      var expected:Array = [
        {'v': 125, 'c': 0xff8000},
        {'v': 155, 'c': 0x80ff00},
      ]
      verifyGradients(gradientControl, expected);

      var xml:XML = 
        <gradientRuleList>
          <gradientRule>
            <gradient>
              <minColor>0xff0000</minColor>
              <maxColor>0xffff00</maxColor>
              <maxPercent>50</maxPercent>
            </gradient>
          </gradientRule>
          <gradientRule>
            <gradient>
              <minColor>0xffff00</minColor>
              <maxColor>0x00ff00</maxColor>
            </gradient>
          </gradientRule>
        </gradientRuleList>;

      var ruleList:GradientRuleList = GradientRuleList.fromXML(xml);
      var gc2:GradientControl = ruleList.applyGradientToValueList(values);
      verifyGradients(gc2, expected);
 
    }

    // First a simple rule, then a recursive one.
    public function testRecursiveGradient():void {
      var values:Array = [300, 400];

      var g1:GradientRule = new GradientRule();
      g1.maxValue = 330;
      g1.minColor = Color.RED;
      g1.maxColor = 0xff8000;

      var g2:GradientRule = new GradientRule();
      g2.maxPercent = 10;
      g2.minColor = Color.YELLOW;
      g2.maxColor = Color.GREEN;

      var g3:GradientRule = new GradientRule();
      g3.maxColor = Color.BLUE;

      var gcr2:GradientRuleList = new GradientRuleList([g2, g3]);
      var gcr:GradientRuleList = new GradientRuleList([g1, gcr2]);

      var gc:GradientControl = gcr.applyGradientToValueList(values);

      var expected:Array = [
        // Values < 330 are handled by g1
        {'v': 315, 'c': 0xff4000},
        // Values below 10% of the range (330, 400) are handled by g2 in gcr2
        {'v': 335, 'c': 0x49ff00},
        // Values above 10% of the range (330, 400) are handled by g3 in gcr2
        {'v': 355, 'c': 0x00b649},
      ]

      verifyGradients(gc, expected);

      var xml:XML = 
        <gradientRuleList>
          <gradientRule>
            <gradient>
              <minColor>0xff0000</minColor>
              <maxColor>0xff8000</maxColor>
              <maxValue>330</maxValue>
            </gradient>
          </gradientRule>
          <gradientRule>
            <gradientRuleList>
              <gradientRule>
                <gradient>
                  <minColor>0xffff00</minColor>
                  <maxColor>0x00ff00</maxColor>
                  <maxPercent>10</maxPercent>
                </gradient>
              </gradientRule>
              <gradientRule>
                <gradient>
                  <maxColor>0x0000ff</maxColor>
                </gradient>
              </gradientRule>
            </gradientRuleList>
          </gradientRule>
        </gradientRuleList>;

      var ruleList:GradientRuleList = GradientRuleList.fromXML(xml);
      var gc2:GradientControl = ruleList.applyGradientToValueList(values);
      verifyGradients(gc2, expected);
 
    }

  // First a recursirve rule, than a simple one.
  public function testRecursiveGradient2():void {
      var values:Array = [300, 400];

      var g1:GradientRule = new GradientRule();
      g1.maxPercent = 20;
      g1.minColor = Color.RED;
      g1.maxColor = 0xff8000;

      var g2:GradientRule = new GradientRule();
      g2.minColor = Color.YELLOW;
      g2.maxColor = Color.GREEN;
      //g2.maxValue = 350 is derived from g3.

      var g3:GradientRule = new GradientRule();
      // g3.minColor = Color.GREEN is derived from g2.
      g3.minValue = 350;
      g3.maxColor = Color.BLUE;

      var gcr:GradientRuleList = new GradientRuleList([g1, g2]);
      var gcr2:GradientRuleList = new GradientRuleList([gcr, g3]);

      var gc:GradientControl = gcr2.applyGradientToValueList(values);

      var expected:Array = [
        // Values < 320 (20% of the range [300, 350]) are handled by g1 in gcr.
        {'v': 305, 'c': 0xff4000},
        // Values > 320 (20% of the range [300, 350]) are handled by g2 in gcr.
        {'v': 335, 'c': 0x60ff00},
        // Values above 350 are handled by g3 
        {'v': 355, 'c': 0x00e61a},
      ]

      verifyGradients(gc, expected);

      var xml:XML = 
        <gradientRuleList>
          <gradientRule>
            <gradientRuleList>
              <gradientRule>
                <gradient>
                  <minColor>0xff0000</minColor>
                  <maxColor>0xff8000</maxColor>
                  <maxPercent>20</maxPercent>
                </gradient>
              </gradientRule>
              <gradientRule>
                <gradient>
                  <minColor>0xffff00</minColor>
                  <maxColor>0x00ff00</maxColor>
                </gradient>
              </gradientRule>
            </gradientRuleList>
          </gradientRule>
          <gradientRule>
            <gradient>
              <maxColor>0x0000ff</maxColor>
              <minValue>350</minValue>
            </gradient>
          </gradientRule>
        </gradientRuleList>;

      var ruleList:GradientRuleList = GradientRuleList.fromXML(xml);
      var gc2:GradientControl = ruleList.applyGradientToValueList(values);
      verifyGradients(gc2, expected);
 
    }
  } 
}
