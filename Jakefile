var ENV = require("system").env,
    FILE = require("file"),
    JAKE = require("jake"),
    task = JAKE.task,
    FileList = JAKE.FileList,
    app = require("cappuccino/jake").app,
    configuration = ENV["CONFIG"] || ENV["CONFIGURATION"] || ENV["c"] || "Debug",
    OS = require("os");

// Obtain a list of Xibs to be converted to Cibs. These are all located in the
// Xibs toplevel directory. We want to return just the name, i.e. 'Xibs/' and '.xib' 
// are stripped off.
function obtainXibs()
{
  var xibs = FILE.glob("Xibs/*.xib");
  for ( var idx = 0 ; idx < xibs.length; idx++ ) {
    xibs[idx] = xibs[idx].substring(0, xibs[idx].length - 4).substring(5);
  }
  return xibs;
}

function printResults(configuration)
{
    print("----------------------------");
    print(configuration+" app built at path: "+FILE.join("Build", configuration, "PublishMeEditor"));
    print("----------------------------");
}

app ("PublishMeEditor", function(task)
{
    task.setBuildIntermediatesPath(FILE.join("Build", "PublishMeEditor.build", configuration));
    task.setBuildPath(FILE.join("Build", configuration));

    task.setProductName("PublishMeEditor");
    task.setIdentifier("es.2monki.publishme.Editor");
    task.setVersion("1.0");
    task.setAuthor("Two Monkeys");
    task.setEmail("feedback @nospam@ 2monki.es");
    task.setSummary("PublishMeEditor");
    task.setSources(new FileList("app/**/*.j", "AppController.j", "main.j"));
    task.setResources(new FileList("Resources/**/**"));
    task.setIndexFilePath("index.html");
    task.setInfoPlistPath("Info.plist");
    task.setNib2CibFlags("-R Resources/");

    if (configuration === "Debug")
        task.setCompilerFlags("-DDEBUG -g");
    else
        task.setCompilerFlags("-O");
});

task ("default", ["nibs", "PublishMeEditor"], function()
{
    printResults(configuration);
});

task ("build", ["nibs", "default"]);

task ("debug", function()
{
    ENV["CONFIGURATION"] = "Debug";
    JAKE.subjake(["."], "build", ENV);
});

task ("release", function()
{
    ENV["CONFIGURATION"] = "Release";
    JAKE.subjake(["."], "build", ENV);
});

task ("run", ["debug"], function()
{
    OS.system(["open", FILE.join("Build", "Debug", "PublishMeEditor", "index.html")]);
});

task ("run-release", ["release"], function()
{
    OS.system(["open", FILE.join("Build", "Release", "PublishMeEditor", "index.html")]);
});

task ("press", ["release"], function()
{
  FILE.mkdirs(FILE.join("Build", "Press", "PublishMeEditor"));
  OS.system(["press", "-f", FILE.join("Build", "Release", "PublishMeEditor"), 
             FILE.join("Build", "Press", "PublishMeEditor")]);
});

task ("deploy", ["release"], function()
{
    FILE.mkdirs(FILE.join("Build", "Deploy", "PublishMeEditor"));
    OS.system(["press", "-f", FILE.join("Build", "Release", "PublishMeEditor"), 
               FILE.join("Build", "Deploy", "PublishMeEditor")]);
    printResults("Deployment");
});


task( "clean-all", function()
{
    OS.system(["rm", "-fr", "Build"]);
});

/*
 * Flatten code with cib caching.
 */
task ("flatten", ["press"], function()
{
  var xibsToConvert = obtainXibs();
  FILE.mkdirs(FILE.join("Build", "Flatten", "PublishMeEditor"));
  var args = ["flatten", "-f", "--verbose", "--split", "4", 
              "-c", "closure-compiler"];
  for ( var idx = 0; idx < xibsToConvert.length; idx++ ) {
    args.push("-P");
    args.push(FILE.join("Resources", xibsToConvert[idx] + ".cib"));
  }
  args.push(FILE.join("Build", "Press", "PublishMeEditor"));
  args.push(FILE.join("Build", "Flatten", "PublishMeEditor"));
  OS.system(args);
});

task( "documentation", [], function()
{
  OS.system("doxygen");
});

task( "cloc", function()
{
  OS.system(["ohcount", "app/", "AppController.j"]);
});

task("test", function()
{
    print("============> WARNING");
    print("Ensure that test filenames are the same as the class that is defined");
    print("E.g. TweetTest.j for TweetTest and not tweet_test.j (i.e. rails style)");
    print("Otherwise you'll get a strange error: >>objj [warn]: unable to get tests<<");
    print("============> END WARNING");

    var tests = new FileList('Test/**/*Test.j');
    var moretests = new FileList('Test/**/*_test.j');
    var cmd = ["ojtest"].concat(tests.items()).concat(moretests.items());
    //print( cmd.map(OS.enquote).join(" ") );
    var cmdString = cmd.map(OS.enquote).join(" ");

    var code = OS.system(cmdString);
    if (code !== 0)
        OS.exit(code);
});

task( "nibs", function()
{
  // Tried using JAKE.file but that didn't not want to work with subdirectories, 
  // i.e. Resources/
  var xibsToConvert = obtainXibs();
  for ( var idx = 0; idx < xibsToConvert.length; idx++ ) {
    var filenameXib = "Resources/../Xibs/" + xibsToConvert[idx] + ".xib";
    var filenameCib = "Resources/" + xibsToConvert[idx] + ".cib";
    if ( !FILE.exists(filenameCib) || FILE.mtime(filenameXib) > FILE.mtime(filenameCib) ) {
      print("Converting to cib: " + filenameXib);
      OS.system(["nib2cib", filenameXib, filenameCib]);
    } else {
      print("Ignoring " + filenameXib + " -> has been converted");
    }
  }
});

