using DynOptInterface
using Documenter

DocMeta.setdocmeta!(DynOptInterface, :DocTestSetup, :(using DynOptInterface); recursive=true)

const _PAGES = [
    "Home" => "index.md",
    "API Reference" => [
        "reference/domains.md",
    ],
]

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
)

deploydocs(;
    repo="github.com/JuDO-dev/DynOptInterface.jl",
    devbranch="dev",
)