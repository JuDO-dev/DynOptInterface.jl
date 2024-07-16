import DynOptInterface
using Documenter
using DocumenterInterLinks
using DocumenterMermaid

DocMeta.setdocmeta!(DynOptInterface, :DocTestSetup, :(import DynOptInterface as DOI); recursive=true)

const _PAGES = [
    #"Home" => "index.md",
    "API Reference" => [
        "Dynamic Functions" => [
            "reference/dynamic_functions/abstraction.md",
            "reference/dynamic_functions/phases.md",
            "reference/dynamic_functions/dynamic_variables.md",
            "reference/dynamic_functions/expressions.md",
            "reference/dynamic_functions/derivatives.md",
        ],
        "reference/boundary_functions.md",
        "reference/nonlinear_support.md",
        "reference/attributes.md",
        "reference/solutions.md",
    ],
]

links = InterLinks(
    "MathOptInterface" => "https://jump.dev/MathOptInterface.jl/v1.31/objects.inv"
)

makedocs(;
    modules=[DynOptInterface],
    authors="Eduardo M. G. Vila <72969764+e-duar-do@users.noreply.github.com> and contributors",
    sitename="DynOptInterface.jl",
    format=Documenter.HTML(;
        canonical="https://JuDO-dev.github.io/DynOptInterface.jl",
        edit_link="dev",
        assets=String[],
    ),
    pages=_PAGES,
    plugins=[links],
)

deploydocs(;
    repo="github.com/JuDO-dev/DynOptInterface.jl",
    devbranch="dev",
)