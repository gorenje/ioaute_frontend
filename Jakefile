
var ENV = require("system").env,
    FILE = require("file"),
    JAKE = require("jake"),
    task = JAKE.task,
    FileList = JAKE.FileList,
    app = require("cappuccino/jake").app,
    configuration = ENV["CONFIG"] || ENV["CONFIGURATION"] || ENV["c"] || "Debug",
    OS = require("os");

app ("PublishMeEditor", function(task)
{
    task.setBuildIntermediatesPath(FILE.join("Build", "PublishMeEditor.build", configuration));
    task.setBuildPath(FILE.join("Build", configuration));

    task.setProductName("PublishMeEditor");
    task.setIdentifier("com.publishme.Editor");
    task.setVersion("1.0");
    task.setAuthor("Your Company");
    task.setEmail("feedback @nospam@ yourcompany.com");
    task.setSummary("PublishMeEditor");
    task.setSources((new FileList("**/*.j")).exclude(FILE.join("Build", "**")));
    task.setResources(new FileList("Resources/**"));
    task.setIndexFilePath("index.html");
    task.setInfoPlistPath("Info.plist");
    task.setNib2CibFlags("-R Resources/");

    if (configuration === "Debug")
        task.setCompilerFlags("-DDEBUG -g");
    else
        task.setCompilerFlags("-O");
});

function printResults(configuration)
{
    print("----------------------------");
    print(configuration+" app built at path: "+FILE.join("Build", configuration, "PublishMeEditor"));
    print("----------------------------");
}

task ("default", ["PublishMeEditor"], function()
{
    printResults(configuration);
});

task( "nibs", function()
{
  OS.system(["nib2cib", "Resources/FlickrWindow.xib", "Resources/FlickrWindow.cib"]);
  OS.system(["nib2cib", "Resources/TwitterWindow.xib", "Resources/TwitterWindow.cib"]);
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

task ("deploy", ["release"], function()
{
    FILE.mkdirs(FILE.join("Build", "Deployment", "PublishMeEditor"));
    OS.system(["press", "-f", FILE.join("Build", "Release", "PublishMeEditor"), FILE.join("Build", "Deployment", "PublishMeEditor")]);
    printResults("Deployment");
});

