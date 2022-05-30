function hit_effects_entity(offset_deviation, offset)
  local offset = offset or {0, 1}
  return {
    type = "create-entity",
    entity_name = "spark-explosion",
    offset_deviation = offset_deviation or {{-0.5, -0.5}, {0.5, 0.5}},
    offsets = {offset},
    damage_type_filters = "fire"
  }
end