# spdgt.wos 0.1.0

* Breaking: one species-agnostic template replaces the per-species templates, so any species can be exported. `wos_md_template` is now `wos_template`, `survey_types` no longer has a `species` column, and the "Extending spdgt.wos" vignette is removed (#15).
* Exports now include incidental observations of other species on the survey, reported as casual observations (activity code 1). New `activity_codes` dataset lists the WOS activity codes (#15).
* Functions now work when called as `spdgt.wos::wos_export()` without `library(spdgt.wos)`; previously they failed with "object 'districts' not found" (#15).
* `wos_export()` gains `out_file` to save the WOS upload spreadsheet in the same step, and validates `species`, `bio_year` and `survey_type` more strictly before calling the API (#15).
* `wos_format()` no longer drops incidental observations that have no classification counts, no longer errors when an observation's `total` is missing, and returns integer count, date and code columns matching `wos_template`. Unclassified animals are reported in `un_unk_qty` so each row adds up to its total, and it warns when classified counts exceed the total. Sightability surveys now report counts instead of blanks (#15).
* `wos_format()` now validates `observer`, `district` and `survey_type` itself, and aborts rather than double-counting when an observation has more than one set of classification counts (#15).
* `wos_read()` is now exported. It returns every observation on the species' survey, matching the survey by the species' own survey type so a same-named analysis unit of another species cannot be mixed in (#15).
* `wos_write_xlsx()` (new) saves an `.xlsx` file in the layout the WOS upload form requires. It needs no system `zip` program or Rtools, and never leaves a partial file behind (#15).

# spdgt.wos 0.0.4

* Initial release, supporting mule deer composition and sightability surveys.
