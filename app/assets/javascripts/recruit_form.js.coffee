$(document).ready ->
  validateInstitutions = ->
    $school = $('#person_school_id')
    school_id = $school.attr('value')
    school_text = $school.next('.autocomplete-schools').attr('value')
    school_ok = !school_text || school_id
    problem_areas = if school_ok then [] else ["School"]

    $college = $('#person_college_id')
    college_id = $college.attr('value')
    college_text = $college.next('.autocomplete-schools').attr('value')
    college_ok = !college_text || college_id
    problem_areas.push("College") unless college_ok

    $club = $('#person_club_id')
    club_id = $club.attr('value')
    club_text = $club.next('.autocomplete-schools').attr('value')
    club_ok = !club_text || club_id
    problem_areas.push("Club") unless club_ok

    problem_text = problem_areas.join(' and ')

    if school_ok && college_ok && club_ok
      return true
    else
      alert("Oops! You entered a #{problem_text} that will not be saved. You need to select your #{problem_text} from the available options. If you can't find your #{problem_text}, click the 'Can't Find Your ... ?' link in order to create a new profile for your #{problem_text}.")
      return false

  $('#person_new input:not(.autocomplete-schools)').bind('change', validateInstitutions)
  $('#person_edit input:not(.autocomplete-schools)').bind('change', validateInstitutions)
  $('#person_new, #person_edit').bind('submit', validateInstitutions)
