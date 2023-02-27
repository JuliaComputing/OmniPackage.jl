using OmniPackage
using Documenter

DocMeta.setdocmeta!(OmniPackage, :DocTestSetup, :(using OmniPackage); recursive=true)

makedocs(;
    modules=[OmniPackage],
    authors="Chris Elrod <elrodc@gmail.com> and contributors",
    repo="https://github.com/chriselrod/OmniPackage.jl/blob/{commit}{path}#{line}",
    sitename="OmniPackage.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
