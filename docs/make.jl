import DynOptInterface
using Documenter
using DocumenterInterLinks

DocMeta.setdocmeta!(DynOptInterface, :DocTestSetup, :(import DynOptInterface as DOI); recursive=true)

const _PAGES = [
    "Home" => "index.md",
    "API Reference" => [
        "reference/abstractions.md",
        "reference/domains.md",
        "reference/dynamic_variables.md",
        "reference/algebraic_functions.md",
        "reference/differential_functions.md",
        "reference/boundary_functions.md",
        "reference/integral_functions.md",
    ],
]

links = InterLinks(
    "MathOptInterface" => "https://jump.dev/MathOptInterface.jl/stable/objects.inv"
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