Fabricator(:form) do
  account!
  name { Fabricate.sequence(:name) { |i| "Some Form #{i}" } }
  html <<EOS
        <label for='hi'>Hi There</label>
        <br />
        <input type='text' name='hi' />
        <label for='whats_up'>Fill it out or suffer the consequences</label>
        <br />
        <textarea name='whats_up' />
        <label for='pick_one[again]'>State</label>
        <br />
        <select name="pick_one[again]">
          <option value="Alabama">Alabama</option>
          <option value="Alaska">Alaska</option>
          <option value="Arizona">Arizona</option>
        </select>
        <br />
        <input id="mood-happy" type="checkbox" name="mood[]" value="happy" />
        <input id="mood-funtime" type="checkbox" name="mood[]" value="funtime" />
        <input id="mood-sad" type="checkbox" name="mood[]" value="sad" />
        <br />
        <input id="hey-there" type="radio" name="hey" value="there" />
        <input id="hey-now" type="radio" name="hey" value="now" />
EOS
end

Fabricator(:other_form, :from => :form) do
  name { Fabricate.sequence(:name) { |i| "Other Form #{i}" } }
  html <<EOS
        <label for='sign'>Sign Off</label>
        <br />
        <input type='text' name='sign' />
        <label for='do_stuff'>Did you do stuff?</label>
        <br />
        <textarea name='do_stuff' />
EOS
end

Fabricator(:third_form, :from => :form) do
  name { Fabricate.sequence(:name) { |i| "Third Form #{i}" } }
  html <<EOS
        <label for='more_yet'>Do more yet</label>
        <br />
        <input type='text' name='more_yet' />
        <label for='baller'>Are you a baller?</label>
        <br />
        <textarea name='baller' />
EOS
end

Fabricator(:filled_in_form, :from => :form) do
  submitter_name "Steve Schwartz"
  public true
  completed_form_data { |f|
    {
      'hi' => 'there',
      'whats_up' => "I'm a recruit.",
      'pick_one' => {'again' => 'Arizona'},
      'mood' => ['happy', 'funtime'],
      'hey' => 'now'
    }
  }
end

Fabricator(:form_with_task, :from => :form) do
  task!
end

Fabricator(:filled_in_form_with_task, :from => :filled_in_form) do
  task!
  submitter_name nil
  assignment { |f| f.task.assignments.first }
  assignee { |f| f.assignment.assignee }
end

Fabricator(:large_form, :from => :form) do
  html <<EOS
          <form action="blah" id="stuff">
          <fieldset class="inputs" name="Personal"><legend><span>Personal</span></legend><ol><li class="string required" id="recruit_first_name_input"><label for="recruit_first_name">First name<abbr title="required">*</abbr></label><input id="recruit_first_name" name="recruit[first_name]" type="text" /></li> 
          <li class="string required" id="recruit_last_name_input"><label for="recruit_last_name">Last name<abbr title="required">*</abbr></label><input id="recruit_last_name" name="recruit[last_name]" type="text" /></li> 
          <li class="string optional" id="recruit_nickname_input"><label for="recruit_nickname">Nickname</label><input id="recruit_nickname" name="recruit[nickname]" type="text" /></li> 
          <li class="string optional" id="recruit_twitter_handle_input"><label for="recruit_twitter_handle">Twitter handle</label><input id="recruit_twitter_handle" name="recruit[twitter_handle]" type="text" /></li> 
          <li class="string optional" id="recruit_facebook_link_input"><label for="recruit_facebook_link">Facebook link</label><input id="recruit_facebook_link" name="recruit[facebook_link]" type="text" /> 
          <p class="inline-hints">eg: http://facebook.com/peter</p></li> 
          <li class="string optional" id="recruit_height_input"><label for="recruit_height">Height</label><input id="recruit_height" name="recruit[height]" type="text" /></li> 
          <li class="string optional" id="recruit_weight_input"><label for="recruit_weight">Weight</label><input id="recruit_weight" name="recruit[weight]" type="text" /></li> 
          <li class="string optional" id="recruit_address_attributes_street_input"><label for="recruit_address_attributes_street">Street</label><input id="recruit_address_attributes_street" name="recruit[address_attributes][street]" type="text" /></li> 
          <li class="string optional" id="recruit_address_attributes_city_input"><label for="recruit_address_attributes_city">City</label><input id="recruit_address_attributes_city" name="recruit[address_attributes][city]" type="text" /></li> 
          <li class='select optional'> 
            <label>State</label> 
            <select class="state" id="recruit_address_attributes_state" name="recruit[address_attributes][state]"><option value="Alabama">Alabama</option> 
            <option value="Alaska">Alaska</option> 
            <option value="Arizona">Arizona</option> 
            <option value="Arkansas">Arkansas</option> 
            <option value="California">California</option> 
            <option value="Colorado">Colorado</option> 
            <option value="Connecticut">Connecticut</option> 
            <option value="Delaware">Delaware</option> 
            <option value="District of Columbia">District of Columbia</option> 
            <option value="Florida">Florida</option> 
            <option value="Georgia">Georgia</option> 
            <option value="Hawaii">Hawaii</option> 
            <option value="Idaho">Idaho</option> 
            <option value="Illinois">Illinois</option> 
            <option value="Indiana">Indiana</option> 
            <option value="Iowa">Iowa</option> 
            <option value="Kansas">Kansas</option> 
            <option value="Kentucky">Kentucky</option> 
            <option value="Louisiana">Louisiana</option> 
            <option value="Maine">Maine</option> 
            <option value="Maryland">Maryland</option> 
            <option value="Massachusetts">Massachusetts</option> 
            <option value="Michigan">Michigan</option> 
            <option value="Minnesota">Minnesota</option> 
            <option value="Mississippi">Mississippi</option> 
            <option value="Missouri">Missouri</option> 
            <option value="Montana">Montana</option> 
            <option value="Nebraska">Nebraska</option> 
            <option value="Nevada">Nevada</option> 
            <option value="New Hampshire">New Hampshire</option> 
            <option value="New Jersey">New Jersey</option> 
            <option value="New Mexico">New Mexico</option> 
            <option value="New York">New York</option> 
            <option value="North Carolina">North Carolina</option> 
            <option value="North Dakota">North Dakota</option> 
            <option value="Ohio">Ohio</option> 
            <option value="Oklahoma">Oklahoma</option> 
            <option value="Oregon">Oregon</option> 
            <option value="Pennsylvania">Pennsylvania</option> 
            <option value="Rhode Island">Rhode Island</option> 
            <option value="South Carolina">South Carolina</option> 
            <option value="South Dakota">South Dakota</option> 
            <option value="Tennessee">Tennessee</option> 
            <option value="Texas">Texas</option> 
            <option value="Utah">Utah</option> 
            <option value="Vermont">Vermont</option> 
            <option value="Virginia">Virginia</option> 
            <option value="Washington">Washington</option> 
            <option value="West Virginia">West Virginia</option> 
            <option value="Wisconsin">Wisconsin</option> 
            <option value="Wyoming">Wyoming</option></select> 
          </li> 
          <li class='select optional'> 
            <label>Country</label> 
            <select class="country" id="recruit_address_attributes_country" name="recruit[address_attributes][country]"><option value=""></option> 
            <option value="United States of America" selected="selected">United States of America</option> 
            <option value="Canada">Canada</option> 
            <option value="-------------" disabled="disabled">-------------</option> 
            <option value="Afghanistan">Afghanistan</option> 
            <option value="Albania">Albania</option> 
            <option value="Algeria">Algeria</option> 
            <option value="American Samoa">American Samoa</option> 
            <option value="Angola">Angola</option> 
            <option value="Anguilla">Anguilla</option> 
            <option value="Antartica">Antartica</option> 
            <option value="Antigua and Barbuda">Antigua and Barbuda</option> 
            <option value="Argentina">Argentina</option> 
            <option value="Armenia">Armenia</option> 
            <option value="Aruba">Aruba</option> 
            <option value="Ashmore and Cartier Island">Ashmore and Cartier Island</option> 
            <option value="Australia">Australia</option> 
            <option value="Austria">Austria</option> 
            <option value="Azerbaijan">Azerbaijan</option> 
            <option value="Bahamas">Bahamas</option> 
            <option value="Bahrain">Bahrain</option> 
            <option value="Bangladesh">Bangladesh</option> 
            <option value="Barbados">Barbados</option> 
            <option value="Belarus">Belarus</option> 
            <option value="Belgium">Belgium</option> 
            <option value="Belize">Belize</option> 
            <option value="Benin">Benin</option> 
            <option value="Bermuda">Bermuda</option> 
            <option value="Bhutan">Bhutan</option> 
            <option value="Bolivia">Bolivia</option> 
            <option value="Bosnia and Herzegovina">Bosnia and Herzegovina</option> 
            <option value="Botswana">Botswana</option> 
            <option value="Bouenza">Bouenza</option> 
            <option value="Brazil">Brazil</option> 
            <option value="Brazzaville">Brazzaville</option> 
            <option value="British Virgin Islands">British Virgin Islands</option> 
            <option value="Brunei">Brunei</option> 
            <option value="Bulgaria">Bulgaria</option> 
            <option value="Burkina Faso">Burkina Faso</option> 
            <option value="Burma">Burma</option> 
            <option value="Burundi">Burundi</option> 
            <option value="Cambodia">Cambodia</option> 
            <option value="Cameroon">Cameroon</option> 
            <option value="Cape Verde">Cape Verde</option> 
            <option value="Cayman Islands">Cayman Islands</option> 
            <option value="Central African Republic">Central African Republic</option> 
            <option value="Chad">Chad</option> 
            <option value="Chile">Chile</option> 
            <option value="China">China</option> 
            <option value="Christmas Island">Christmas Island</option> 
            <option value="Clipperton Island">Clipperton Island</option> 
            <option value="Cocos (Keeling) Islands">Cocos (Keeling) Islands</option> 
            <option value="Colombia">Colombia</option> 
            <option value="Comoros">Comoros</option> 
            <option value="Congo">Congo</option> 
            <option value="Cook Islands">Cook Islands</option> 
            <option value="Costa Rica">Costa Rica</option> 
            <option value="Croatia">Croatia</option> 
            <option value="Cuba">Cuba</option> 
            <option value="Cuvette">Cuvette</option> 
            <option value="Cyprus">Cyprus</option> 
            <option value="Czeck Republic">Czeck Republic</option> 
            <option value="Denmark">Denmark</option> 
            <option value="Djibouti">Djibouti</option> 
            <option value="Dominica">Dominica</option> 
            <option value="Dominican Republic">Dominican Republic</option> 
            <option value="Ecuador">Ecuador</option> 
            <option value="Egypt">Egypt</option> 
            <option value="El Salvador">El Salvador</option> 
            <option value="England">England</option> 
            <option value="Equatorial Guinea">Equatorial Guinea</option> 
            <option value="Eritrea">Eritrea</option> 
            <option value="Estonia">Estonia</option> 
            <option value="Ethiopia">Ethiopia</option> 
            <option value="Europa Island">Europa Island</option> 
            <option value="Falkland Islands (Islas Malvinas)">Falkland Islands (Islas Malvinas)</option> 
            <option value="Faroe Islands">Faroe Islands</option> 
            <option value="Fiji">Fiji</option> 
            <option value="Finland">Finland</option> 
            <option value="France">France</option> 
            <option value="French Guiana">French Guiana</option> 
            <option value="French Polynesia">French Polynesia</option> 
            <option value="French Southern and Antarctic Lands">French Southern and Antarctic Lands</option> 
            <option value="Gabon">Gabon</option> 
            <option value="Gambia">Gambia</option> 
            <option value="Gaza Strip">Gaza Strip</option> 
            <option value="Georgia">Georgia</option> 
            <option value="Germany">Germany</option> 
            <option value="Ghana">Ghana</option> 
            <option value="Gibraltar">Gibraltar</option> 
            <option value="Glorioso Islands">Glorioso Islands</option> 
            <option value="Greece">Greece</option> 
            <option value="Greenland">Greenland</option> 
            <option value="Grenada">Grenada</option> 
            <option value="Guadeloupe">Guadeloupe</option> 
            <option value="Guam">Guam</option> 
            <option value="Guatemala">Guatemala</option> 
            <option value="Guernsey">Guernsey</option> 
            <option value="Guinea">Guinea</option> 
            <option value="Guinea-Bissau">Guinea-Bissau</option> 
            <option value="Guyana">Guyana</option> 
            <option value="Haiti">Haiti</option> 
            <option value="Heard Island and McDonald Islands">Heard Island and McDonald Islands</option> 
            <option value="Holy See (Vatican City)">Holy See (Vatican City)</option> 
            <option value="Honduras">Honduras</option> 
            <option value="Hong Kong">Hong Kong</option> 
            <option value="Howland Island">Howland Island</option> 
            <option value="Hungary">Hungary</option> 
            <option value="Iceland">Iceland</option> 
            <option value="India">India</option> 
            <option value="Indonesia">Indonesia</option> 
            <option value="Iran">Iran</option> 
            <option value="Iraq">Iraq</option> 
            <option value="Ireland">Ireland</option> 
            <option value="Israel">Israel</option> 
            <option value="Italy">Italy</option> 
            <option value="Jamaica">Jamaica</option> 
            <option value="Jan Mayen">Jan Mayen</option> 
            <option value="Japan">Japan</option> 
            <option value="Jarvis Island">Jarvis Island</option> 
            <option value="Jersey">Jersey</option> 
            <option value="Johnston Atoll">Johnston Atoll</option> 
            <option value="Jordan">Jordan</option> 
            <option value="Juan de Nova Island">Juan de Nova Island</option> 
            <option value="Kazakhstan">Kazakhstan</option> 
            <option value="Kenya">Kenya</option> 
            <option value="Kiribati">Kiribati</option> 
            <option value="Korea">Korea</option> 
            <option value="Kouilou">Kouilou</option> 
            <option value="Kuwait">Kuwait</option> 
            <option value="Kyrgyzstan">Kyrgyzstan</option> 
            <option value="Laos">Laos</option> 
            <option value="Latvia">Latvia</option> 
            <option value="Lebanon">Lebanon</option> 
            <option value="Lekoumou">Lekoumou</option> 
            <option value="Lesotho">Lesotho</option> 
            <option value="Liberia">Liberia</option> 
            <option value="Libya">Libya</option> 
            <option value="Liechtenstein">Liechtenstein</option> 
            <option value="Likouala">Likouala</option> 
            <option value="Lithuania">Lithuania</option> 
            <option value="Luxembourg">Luxembourg</option> 
            <option value="Macau">Macau</option> 
            <option value="Macedonia">Macedonia</option> 
            <option value="Madagascar">Madagascar</option> 
            <option value="Malawi">Malawi</option> 
            <option value="Malaysia">Malaysia</option> 
            <option value="Maldives">Maldives</option> 
            <option value="Mali">Mali</option> 
            <option value="Malta">Malta</option> 
            <option value="Marshall Islands">Marshall Islands</option> 
            <option value="Martinique">Martinique</option> 
            <option value="Mauritania">Mauritania</option> 
            <option value="Mauritius">Mauritius</option> 
            <option value="Mayotte">Mayotte</option> 
            <option value="Mexico">Mexico</option> 
            <option value="Micronesia">Micronesia</option> 
            <option value="Midway Islands">Midway Islands</option> 
            <option value="Moldova">Moldova</option> 
            <option value="Monaco">Monaco</option> 
            <option value="Mongolia">Mongolia</option> 
            <option value="Montserrat">Montserrat</option> 
            <option value="Morocco">Morocco</option> 
            <option value="Mozambique">Mozambique</option> 
            <option value="Namibia">Namibia</option> 
            <option value="Nauru">Nauru</option> 
            <option value="Nepal">Nepal</option> 
            <option value="Netherlands">Netherlands</option> 
            <option value="Netherlands Antilles">Netherlands Antilles</option> 
            <option value="New Caledonia">New Caledonia</option> 
            <option value="New Zealand">New Zealand</option> 
            <option value="Niari">Niari</option> 
            <option value="Nicaragua">Nicaragua</option> 
            <option value="Niger">Niger</option> 
            <option value="Nigeria">Nigeria</option> 
            <option value="Niue">Niue</option> 
            <option value="Norfolk Island">Norfolk Island</option> 
            <option value="Northern Mariana Islands">Northern Mariana Islands</option> 
            <option value="Norway">Norway</option> 
            <option value="Oman">Oman</option> 
            <option value="Pakistan">Pakistan</option> 
            <option value="Palau">Palau</option> 
            <option value="Panama">Panama</option> 
            <option value="Papua New Guinea">Papua New Guinea</option> 
            <option value="Paraguay">Paraguay</option> 
            <option value="Peru">Peru</option> 
            <option value="Philippines">Philippines</option> 
            <option value="Pitcaim Islands">Pitcaim Islands</option> 
            <option value="Plateaux">Plateaux</option> 
            <option value="Poland">Poland</option> 
            <option value="Pool">Pool</option> 
            <option value="Portugal">Portugal</option> 
            <option value="Puerto Rico">Puerto Rico</option> 
            <option value="Qatar">Qatar</option> 
            <option value="Reunion">Reunion</option> 
            <option value="Romainia">Romainia</option> 
            <option value="Russia">Russia</option> 
            <option value="Rwanda">Rwanda</option> 
            <option value="Saint Helena">Saint Helena</option> 
            <option value="Saint Kitts and Nevis">Saint Kitts and Nevis</option> 
            <option value="Saint Lucia">Saint Lucia</option> 
            <option value="Saint Pierre and Miquelon">Saint Pierre and Miquelon</option> 
            <option value="Saint Vincent and the Grenadines">Saint Vincent and the Grenadines</option> 
            <option value="Samoa">Samoa</option> 
            <option value="San Marino">San Marino</option> 
            <option value="Sangha">Sangha</option> 
            <option value="Sao Tome and Principe">Sao Tome and Principe</option> 
            <option value="Saudi Arabia">Saudi Arabia</option> 
            <option value="Scotland">Scotland</option> 
            <option value="Senegal">Senegal</option> 
            <option value="Seychelles">Seychelles</option> 
            <option value="Sierra Leone">Sierra Leone</option> 
            <option value="Singapore">Singapore</option> 
            <option value="Slovakia">Slovakia</option> 
            <option value="Slovenia">Slovenia</option> 
            <option value="Solomon Islands">Solomon Islands</option> 
            <option value="Somalia">Somalia</option> 
            <option value="South Africa">South Africa</option> 
            <option value="South Georgia and South Sandwich Islands">South Georgia and South Sandwich Islands</option> 
            <option value="Spain">Spain</option> 
            <option value="Spratly Islands">Spratly Islands</option> 
            <option value="Sri Lanka">Sri Lanka</option> 
            <option value="Sudan">Sudan</option> 
            <option value="Suriname">Suriname</option> 
            <option value="Svalbard">Svalbard</option> 
            <option value="Swaziland">Swaziland</option> 
            <option value="Sweden">Sweden</option> 
            <option value="Switzerland">Switzerland</option> 
            <option value="Syria">Syria</option> 
            <option value="Taiwan">Taiwan</option> 
            <option value="Tajikistan">Tajikistan</option> 
            <option value="Tanzania">Tanzania</option> 
            <option value="Thailand">Thailand</option> 
            <option value="Tobago">Tobago</option> 
            <option value="Toga">Toga</option> 
            <option value="Tokelau">Tokelau</option> 
            <option value="Tonga">Tonga</option> 
            <option value="Trinidad">Trinidad</option> 
            <option value="Tunisia">Tunisia</option> 
            <option value="Turkey">Turkey</option> 
            <option value="Turkmenistan">Turkmenistan</option> 
            <option value="Tuvalu">Tuvalu</option> 
            <option value="ULL">ULL</option> 
            <option value="Uganda">Uganda</option> 
            <option value="Ukraine">Ukraine</option> 
            <option value="United Arab Emirates">United Arab Emirates</option> 
            <option value="Uruguay">Uruguay</option> 
            <option value="Uzbekistan">Uzbekistan</option> 
            <option value="Vanuatu">Vanuatu</option> 
            <option value="Venezuela">Venezuela</option> 
            <option value="Vietnam">Vietnam</option> 
            <option value="Virgin Islands">Virgin Islands</option> 
            <option value="Wales">Wales</option> 
            <option value="Wallis and Futuna">Wallis and Futuna</option> 
            <option value="West Bank">West Bank</option> 
            <option value="Western Sahara">Western Sahara</option> 
            <option value="Yemen">Yemen</option> 
            <option value="Yugoslavia">Yugoslavia</option> 
            <option value="Zambia">Zambia</option> 
            <option value="Zimbabwe">Zimbabwe</option></select> 
          </li> 
          <li class="string optional" id="recruit_address_attributes_post_code_input"><label for="recruit_address_attributes_post_code">Post code</label><input id="recruit_address_attributes_post_code" name="recruit[address_attributes][post_code]" type="text" /></li> 
          <li class="string optional" id="recruit_home_phone_input"><label for="recruit_home_phone">Home phone</label><input id="recruit_home_phone" name="recruit[home_phone]" type="text" value="" /></li> 
          <li class="string optional" id="recruit_cell_phone_input"><label for="recruit_cell_phone">Cell phone</label><input id="recruit_cell_phone" name="recruit[cell_phone]" type="text" value="" /></li> 
          <li class="string optional" id="recruit_email_input"><label for="recruit_email">Email</label><input id="recruit_email" name="recruit[email]" type="text" /></li> 
          <li class="string optional" id="recruit_birthdate_input"><label for="recruit_birthdate">Birthdate</label><input id="recruit_birthdate" name="recruit[birthdate]" type="text" /></li> 
          <li class="string optional" id="recruit_fathers_name_input"><label for="recruit_fathers_name">Fathers name</label><input id="recruit_fathers_name" name="recruit[fathers_name]" type="text" /></li> 
          <li class="string optional" id="recruit_fathers_occupation_input"><label for="recruit_fathers_occupation">Fathers occupation</label><input id="recruit_fathers_occupation" name="recruit[fathers_occupation]" type="text" /></li> 
          <li class="string optional" id="recruit_fathers_phone_input"><label for="recruit_fathers_phone">Fathers phone</label><input id="recruit_fathers_phone" name="recruit[fathers_phone]" type="text" value="" /></li> 
          <li class="string optional" id="recruit_fathers_email_input"><label for="recruit_fathers_email">Fathers email</label><input id="recruit_fathers_email" name="recruit[fathers_email]" type="text" /></li> 
          <li class="string optional" id="recruit_fathers_college_input"><label for="recruit_fathers_college">Fathers college</label><input id="recruit_fathers_college" name="recruit[fathers_college]" type="text" /></li> 
          <li class="string optional" id="recruit_mothers_name_input"><label for="recruit_mothers_name">Mothers name</label><input id="recruit_mothers_name" name="recruit[mothers_name]" type="text" /></li> 
          <li class="string optional" id="recruit_mothers_occupation_input"><label for="recruit_mothers_occupation">Mothers occupation</label><input id="recruit_mothers_occupation" name="recruit[mothers_occupation]" type="text" /></li> 
          <li class="string optional" id="recruit_mothers_phone_input"><label for="recruit_mothers_phone">Mothers phone</label><input id="recruit_mothers_phone" name="recruit[mothers_phone]" type="text" value="" /></li> 
          <li class="string optional" id="recruit_mothers_email_input"><label for="recruit_mothers_email">Mothers email</label><input id="recruit_mothers_email" name="recruit[mothers_email]" type="text" /></li> 
          <li class="string optional" id="recruit_mothers_college_input"><label for="recruit_mothers_college">Mothers college</label><input id="recruit_mothers_college" name="recruit[mothers_college]" type="text" /></li> 
          <li class="select optional" id="recruit_lives_with_input"><label for="recruit_lives_with">Lives with</label><select id="recruit_lives_with" name="recruit[lives_with]"><option value=""></option> 
          <option value="Both">Both</option> 
          <option value="Mother">Mother</option> 
          <option value="Father">Father</option> 
          <option value="Other">Other</option></select></li> 
          <li class="text optional" id="recruit_siblings_input"><label for="recruit_siblings">Siblings</label><textarea id="recruit_siblings" name="recruit[siblings]" rows="20"></textarea></li> 
          <li class="text optional" id="recruit_friends_relatives_input"><label for="recruit_friends_relatives">Friends relatives</label><textarea id="recruit_friends_relatives" name="recruit[friends_relatives]" rows="20"></textarea></li> 
          <li class="text optional" id="recruit_hobbies_input"><label for="recruit_hobbies">Hobbies</label><textarea id="recruit_hobbies" name="recruit[hobbies]" rows="20"></textarea></li> 
          <li class="file optional" id="recruit_photo_input"><label for="recruit_photo">Photo</label><input id="recruit_photo" name="recruit[photo]" type="file" /></li> 
          </ol></fieldset> 
          <fieldset class="inputs" name="Academic"><legend><span>Academic</span></legend><ol><!-- / TODO High School selection --> 
          <!-- / TODO Extract Year selection list --> 
          <li class='string optional'> 
            <label for='recruit_school'>High School</label> 
            <input id="recruit_school_id" name="recruit[school_id]" type="hidden" /> 
            <input class="autocomplete-schools" data-update="#recruit_school_id" data-url="/institutions/search.json" id="school" name="school" type="text" /> 
            <p class='inline-hints'> 
              <a href="/institutions/new" class="new-school-link">Can't find your school?</a> 
            </p> 
          </li> 
          <li class="select optional" id="recruit_graduation_year_input"><label for="recruit_graduation_year">Graduation year</label><select id="recruit_graduation_year" name="recruit[graduation_year]"><option value=""></option> 
          <option value="2006">2006</option> 
          <option value="2007">2007</option> 
          <option value="2008">2008</option> 
          <option value="2009">2009</option> 
          <option value="2010">2010</option> 
          <option value="2011">2011</option> 
          <option value="2012">2012</option> 
          <option value="2013">2013</option> 
          <option value="2014">2014</option> 
          <option value="2015">2015</option> 
          <option value="2016">2016</option> 
          <option value="2017">2017</option> 
          <option value="2018">2018</option> 
          <option value="2019">2019</option> 
          <option value="2020">2020</option> 
          <option value="2021">2021</option></select></li> 
          <li class="string optional" id="recruit_gpa_input"><label for="recruit_gpa">Gpa</label><input id="recruit_gpa" name="recruit[gpa]" type="text" /></li> 
          <li class="string optional" id="recruit_gpa_out_of_input"><label for="recruit_gpa_out_of">Gpa out of</label><input id="recruit_gpa_out_of" name="recruit[gpa_out_of]" type="text" /></li> 
          <li class="string optional" id="recruit_sat_verbal_input"><label for="recruit_sat_verbal">Sat verbal</label><input id="recruit_sat_verbal" name="recruit[sat_verbal]" type="text" /></li> 
          <li class="string optional" id="recruit_sat_math_input"><label for="recruit_sat_math">Sat math</label><input id="recruit_sat_math" name="recruit[sat_math]" type="text" /></li> 
          <li class="string optional" id="recruit_sat_writing_input"><label for="recruit_sat_writing">Sat writing</label><input id="recruit_sat_writing" name="recruit[sat_writing]" type="text" /></li> 
          <li class="string optional" id="recruit_sat_total_input"><label for="recruit_sat_total">Sat total</label><input id="recruit_sat_total" name="recruit[sat_total]" type="text" /></li> 
          <li class="string optional" id="recruit_act_math_input"><label for="recruit_act_math">Act math</label><input id="recruit_act_math" name="recruit[act_math]" type="text" /></li> 
          <li class="string optional" id="recruit_act_english_input"><label for="recruit_act_english">Act english</label><input id="recruit_act_english" name="recruit[act_english]" type="text" /></li> 
          <li class="string optional" id="recruit_act_reading_input"><label for="recruit_act_reading">Act reading</label><input id="recruit_act_reading" name="recruit[act_reading]" type="text" /></li> 
          <li class="string optional" id="recruit_act_science_input"><label for="recruit_act_science">Act science</label><input id="recruit_act_science" name="recruit[act_science]" type="text" /></li> 
          <li class="string optional" id="recruit_act_total_input"><label for="recruit_act_total">Act total</label><input id="recruit_act_total" name="recruit[act_total]" type="text" /></li> 
          <li class="string optional" id="recruit_class_rank_input"><label for="recruit_class_rank">Class rank</label><input id="recruit_class_rank" name="recruit[class_rank]" type="text" /></li> 
          <li class="string optional" id="recruit_class_rank_out_of_input"><label for="recruit_class_rank_out_of">Class rank out of</label><input id="recruit_class_rank_out_of" name="recruit[class_rank_out_of]" type="text" /></li> 
          <li class="text optional" id="recruit_counselor_info_input"><label for="recruit_counselor_info">Counselor info</label><textarea id="recruit_counselor_info" name="recruit[counselor_info]" rows="20"></textarea></li> 
          <li class="string optional" id="recruit_major_input"><label for="recruit_major">Major</label><input id="recruit_major" name="recruit[major]" type="text" /></li> 
          <li class="string optional" id="recruit_honors_awards_input"><label for="recruit_honors_awards">Honors awards</label><input id="recruit_honors_awards" name="recruit[honors_awards]" type="text" /></li> 
          <li class="string optional" id="recruit_top_colleges_input"><label for="recruit_top_colleges">Top colleges</label><input id="recruit_top_colleges" name="recruit[top_colleges]" type="text" /></li> 
          <li class="select optional" id="recruit_applied_for_admission_input"><label for="recruit_applied_for_admission">Applied for admission</label><select id="recruit_applied_for_admission" name="recruit[applied_for_admission]"><option value=""></option> 
          <option value="Yes">Yes</option> 
          <option value="No">No</option> 
          <option value="In Process">In Process</option></select></li> 
          <li class="string optional" id="recruit_school_interest_input"><label for="recruit_school_interest">School interest</label><input id="recruit_school_interest" name="recruit[school_interest]" type="text" /></li> 
          <li class="string optional" id="recruit_financial_aid_input"><label for="recruit_financial_aid">Financial aid</label><input id="recruit_financial_aid" name="recruit[financial_aid]" type="text" /></li> 
          <li class="boolean optional" id="recruit_transcripts_received_input"><input name="recruit[transcripts_received]" type="hidden" value="0" /><label for="recruit_transcripts_received"><input id="recruit_transcripts_received" name="recruit[transcripts_received]" type="checkbox" value="1" />Transcripts received</label></li> 
          </ol></fieldset> 
          <fieldset class="inputs" name="Athletic Details"><legend><span>Athletic Details</span></legend><ol><li class="string optional" id="recruit_sport_name_input"><label for="recruit_sport_name">Sport name</label><input id="recruit_sport_name" name="recruit[sport_name]" type="text" /></li> 
          <li class="string optional" id="recruit_conference_input"><label for="recruit_conference">Conference</label><input id="recruit_conference" name="recruit[conference]" type="text" /></li> 
          <li class="string optional" id="recruit_division_input"><label for="recruit_division">Division</label><input id="recruit_division" name="recruit[division]" type="text" /></li> 
          <li class="string optional" id="recruit_title_input"><label for="recruit_title">Title</label><input id="recruit_title" name="recruit[title]" type="text" /></li> 
          <li class="string optional" id="recruit_referral_input"><label for="recruit_referral">Referral</label><input id="recruit_referral" name="recruit[referral]" type="text" /></li> 
          <li class="string optional" id="recruit_first_contact_input"><label for="recruit_first_contact">First contact</label><input id="recruit_first_contact" name="recruit[first_contact]" type="text" /></li> 
          <li class="string optional" id="recruit_individual_accomplishments_input"><label for="recruit_individual_accomplishments">Individual accomplishments</label><input id="recruit_individual_accomplishments" name="recruit[individual_accomplishments]" type="text" /></li> 
          <li class="text optional" id="recruit_high_school_coach_info_input"><label for="recruit_high_school_coach_info">High school coach info</label><textarea id="recruit_high_school_coach_info" name="recruit[high_school_coach_info]" rows="20"></textarea></li> 
          <li class="string optional" id="recruit_ncaa_clearinghouse_id_input"><label for="recruit_ncaa_clearinghouse_id">Ncaa clearinghouse</label><input id="recruit_ncaa_clearinghouse_id" name="recruit[ncaa_clearinghouse_id]" type="text" /></li> 
          <li class="string optional" id="recruit_other_sports_played_input"><label for="recruit_other_sports_played">Other sports played</label><input id="recruit_other_sports_played" name="recruit[other_sports_played]" type="text" /></li> 
          <li class="string optional" id="recruit_schedule_input"><label for="recruit_schedule">Schedule</label><input id="recruit_schedule" name="recruit[schedule]" type="text" /></li> 
          <li class="string optional" id="recruit_links_input"><label for="recruit_links">Links</label><input id="recruit_links" name="recruit[links]" type="text" /></li> 
          </ol></fieldset> 
          <fieldset class="buttons"><ol><li class="commit"><input class="create" id="recruit_submit" name="commit" type="submit" value="Create Sales" /></li></ol></fieldset> 
        </form> 
        <div class='institution-dialog' title='Create New School'> 
          <form accept-charset="UTF-8" action="/institutions" class="formtastic institution" data-remote="true" data-type="json" id="institution_new" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="14Bq/+rptIulmdL89KczFY7Y1wU6B9bZ301NyBoPpM8=" /></div> 
            <fieldset class="inputs"><ol><li class="string optional" id="institution_name_input"><label for="institution_name">Name</label><input id="institution_name" name="institution[name]" type="text" /></li> 
            <li class="string optional" id="institution_address_attributes_street_input"><label for="institution_address_attributes_street">Street</label><input id="institution_address_attributes_street" name="institution[address_attributes][street]" type="text" /></li> 
            <li class="string optional" id="institution_address_attributes_city_input"><label for="institution_address_attributes_city">City</label><input id="institution_address_attributes_city" name="institution[address_attributes][city]" type="text" /></li> 
            <li class='select optional'> 
              <label>State</label> 
              <select class="state" id="institution_address_attributes_state" name="institution[address_attributes][state]"><option value="Alabama">Alabama</option> 
              <option value="Alaska">Alaska</option> 
              <option value="Arizona">Arizona</option> 
              <option value="Arkansas">Arkansas</option> 
              <option value="California">California</option> 
              <option value="Colorado">Colorado</option> 
              <option value="Connecticut">Connecticut</option> 
              <option value="Delaware">Delaware</option> 
              <option value="District of Columbia">District of Columbia</option> 
              <option value="Florida">Florida</option> 
              <option value="Georgia">Georgia</option> 
              <option value="Hawaii">Hawaii</option> 
              <option value="Idaho">Idaho</option> 
              <option value="Illinois">Illinois</option> 
              <option value="Indiana">Indiana</option> 
              <option value="Iowa">Iowa</option> 
              <option value="Kansas">Kansas</option> 
              <option value="Kentucky">Kentucky</option> 
              <option value="Louisiana">Louisiana</option> 
              <option value="Maine">Maine</option> 
              <option value="Maryland">Maryland</option> 
              <option value="Massachusetts">Massachusetts</option> 
              <option value="Michigan">Michigan</option> 
              <option value="Minnesota">Minnesota</option> 
              <option value="Mississippi">Mississippi</option> 
              <option value="Missouri">Missouri</option> 
              <option value="Montana">Montana</option> 
              <option value="Nebraska">Nebraska</option> 
              <option value="Nevada">Nevada</option> 
              <option value="New Hampshire">New Hampshire</option> 
              <option value="New Jersey">New Jersey</option> 
              <option value="New Mexico">New Mexico</option> 
              <option value="New York">New York</option> 
              <option value="North Carolina">North Carolina</option> 
              <option value="North Dakota">North Dakota</option> 
              <option value="Ohio">Ohio</option> 
              <option value="Oklahoma">Oklahoma</option> 
              <option value="Oregon">Oregon</option> 
              <option value="Pennsylvania">Pennsylvania</option> 
              <option value="Rhode Island">Rhode Island</option> 
              <option value="South Carolina">South Carolina</option> 
              <option value="South Dakota">South Dakota</option> 
              <option value="Tennessee">Tennessee</option> 
              <option value="Texas">Texas</option> 
              <option value="Utah">Utah</option> 
              <option value="Vermont">Vermont</option> 
              <option value="Virginia">Virginia</option> 
              <option value="Washington">Washington</option> 
              <option value="West Virginia">West Virginia</option> 
              <option value="Wisconsin">Wisconsin</option> 
              <option value="Wyoming">Wyoming</option></select> 
            </li> 
            <li class='select optional'> 
              <label>Country</label> 
              <select class="country" id="institution_address_attributes_country" name="institution[address_attributes][country]"><option value=""></option> 
              <option value="United States of America" selected="selected">United States of America</option> 
              <option value="Canada">Canada</option> 
              <option value="-------------" disabled="disabled">-------------</option> 
              <option value="Afghanistan">Afghanistan</option> 
              <option value="Albania">Albania</option> 
              <option value="Algeria">Algeria</option> 
              <option value="American Samoa">American Samoa</option> 
              <option value="Angola">Angola</option> 
              <option value="Anguilla">Anguilla</option> 
              <option value="Antartica">Antartica</option> 
              <option value="Antigua and Barbuda">Antigua and Barbuda</option> 
              <option value="Argentina">Argentina</option> 
              <option value="Armenia">Armenia</option> 
              <option value="Aruba">Aruba</option> 
              <option value="Ashmore and Cartier Island">Ashmore and Cartier Island</option> 
              <option value="Australia">Australia</option> 
              <option value="Austria">Austria</option> 
              <option value="Azerbaijan">Azerbaijan</option> 
              <option value="Bahamas">Bahamas</option> 
              <option value="Bahrain">Bahrain</option> 
              <option value="Bangladesh">Bangladesh</option> 
              <option value="Barbados">Barbados</option> 
              <option value="Belarus">Belarus</option> 
              <option value="Belgium">Belgium</option> 
              <option value="Belize">Belize</option> 
              <option value="Benin">Benin</option> 
              <option value="Bermuda">Bermuda</option> 
              <option value="Bhutan">Bhutan</option> 
              <option value="Bolivia">Bolivia</option> 
              <option value="Bosnia and Herzegovina">Bosnia and Herzegovina</option> 
              <option value="Botswana">Botswana</option> 
              <option value="Bouenza">Bouenza</option> 
              <option value="Brazil">Brazil</option> 
              <option value="Brazzaville">Brazzaville</option> 
              <option value="British Virgin Islands">British Virgin Islands</option> 
              <option value="Brunei">Brunei</option> 
              <option value="Bulgaria">Bulgaria</option> 
              <option value="Burkina Faso">Burkina Faso</option> 
              <option value="Burma">Burma</option> 
              <option value="Burundi">Burundi</option> 
              <option value="Cambodia">Cambodia</option> 
              <option value="Cameroon">Cameroon</option> 
              <option value="Cape Verde">Cape Verde</option> 
              <option value="Cayman Islands">Cayman Islands</option> 
              <option value="Central African Republic">Central African Republic</option> 
              <option value="Chad">Chad</option> 
              <option value="Chile">Chile</option> 
              <option value="China">China</option> 
              <option value="Christmas Island">Christmas Island</option> 
              <option value="Clipperton Island">Clipperton Island</option> 
              <option value="Cocos (Keeling) Islands">Cocos (Keeling) Islands</option> 
              <option value="Colombia">Colombia</option> 
              <option value="Comoros">Comoros</option> 
              <option value="Congo">Congo</option> 
              <option value="Cook Islands">Cook Islands</option> 
              <option value="Costa Rica">Costa Rica</option> 
              <option value="Croatia">Croatia</option> 
              <option value="Cuba">Cuba</option> 
              <option value="Cuvette">Cuvette</option> 
              <option value="Cyprus">Cyprus</option> 
              <option value="Czeck Republic">Czeck Republic</option> 
              <option value="Denmark">Denmark</option> 
              <option value="Djibouti">Djibouti</option> 
              <option value="Dominica">Dominica</option> 
              <option value="Dominican Republic">Dominican Republic</option> 
              <option value="Ecuador">Ecuador</option> 
              <option value="Egypt">Egypt</option> 
              <option value="El Salvador">El Salvador</option> 
              <option value="England">England</option> 
              <option value="Equatorial Guinea">Equatorial Guinea</option> 
              <option value="Eritrea">Eritrea</option> 
              <option value="Estonia">Estonia</option> 
              <option value="Ethiopia">Ethiopia</option> 
              <option value="Europa Island">Europa Island</option> 
              <option value="Falkland Islands (Islas Malvinas)">Falkland Islands (Islas Malvinas)</option> 
              <option value="Faroe Islands">Faroe Islands</option> 
              <option value="Fiji">Fiji</option> 
              <option value="Finland">Finland</option> 
              <option value="France">France</option> 
              <option value="French Guiana">French Guiana</option> 
              <option value="French Polynesia">French Polynesia</option> 
              <option value="French Southern and Antarctic Lands">French Southern and Antarctic Lands</option> 
              <option value="Gabon">Gabon</option> 
              <option value="Gambia">Gambia</option> 
              <option value="Gaza Strip">Gaza Strip</option> 
              <option value="Georgia">Georgia</option> 
              <option value="Germany">Germany</option> 
              <option value="Ghana">Ghana</option> 
              <option value="Gibraltar">Gibraltar</option> 
              <option value="Glorioso Islands">Glorioso Islands</option> 
              <option value="Greece">Greece</option> 
              <option value="Greenland">Greenland</option> 
              <option value="Grenada">Grenada</option> 
              <option value="Guadeloupe">Guadeloupe</option> 
              <option value="Guam">Guam</option> 
              <option value="Guatemala">Guatemala</option> 
              <option value="Guernsey">Guernsey</option> 
              <option value="Guinea">Guinea</option> 
              <option value="Guinea-Bissau">Guinea-Bissau</option> 
              <option value="Guyana">Guyana</option> 
              <option value="Haiti">Haiti</option> 
              <option value="Heard Island and McDonald Islands">Heard Island and McDonald Islands</option> 
              <option value="Holy See (Vatican City)">Holy See (Vatican City)</option> 
              <option value="Honduras">Honduras</option> 
              <option value="Hong Kong">Hong Kong</option> 
              <option value="Howland Island">Howland Island</option> 
              <option value="Hungary">Hungary</option> 
              <option value="Iceland">Iceland</option> 
              <option value="India">India</option> 
              <option value="Indonesia">Indonesia</option> 
              <option value="Iran">Iran</option> 
              <option value="Iraq">Iraq</option> 
              <option value="Ireland">Ireland</option> 
              <option value="Israel">Israel</option> 
              <option value="Italy">Italy</option> 
              <option value="Jamaica">Jamaica</option> 
              <option value="Jan Mayen">Jan Mayen</option> 
              <option value="Japan">Japan</option> 
              <option value="Jarvis Island">Jarvis Island</option> 
              <option value="Jersey">Jersey</option> 
              <option value="Johnston Atoll">Johnston Atoll</option> 
              <option value="Jordan">Jordan</option> 
              <option value="Juan de Nova Island">Juan de Nova Island</option> 
              <option value="Kazakhstan">Kazakhstan</option> 
              <option value="Kenya">Kenya</option> 
              <option value="Kiribati">Kiribati</option> 
              <option value="Korea">Korea</option> 
              <option value="Kouilou">Kouilou</option> 
              <option value="Kuwait">Kuwait</option> 
              <option value="Kyrgyzstan">Kyrgyzstan</option> 
              <option value="Laos">Laos</option> 
              <option value="Latvia">Latvia</option> 
              <option value="Lebanon">Lebanon</option> 
              <option value="Lekoumou">Lekoumou</option> 
              <option value="Lesotho">Lesotho</option> 
              <option value="Liberia">Liberia</option> 
              <option value="Libya">Libya</option> 
              <option value="Liechtenstein">Liechtenstein</option> 
              <option value="Likouala">Likouala</option> 
              <option value="Lithuania">Lithuania</option> 
              <option value="Luxembourg">Luxembourg</option> 
              <option value="Macau">Macau</option> 
              <option value="Macedonia">Macedonia</option> 
              <option value="Madagascar">Madagascar</option> 
              <option value="Malawi">Malawi</option> 
              <option value="Malaysia">Malaysia</option> 
              <option value="Maldives">Maldives</option> 
              <option value="Mali">Mali</option> 
              <option value="Malta">Malta</option> 
              <option value="Marshall Islands">Marshall Islands</option> 
              <option value="Martinique">Martinique</option> 
              <option value="Mauritania">Mauritania</option> 
              <option value="Mauritius">Mauritius</option> 
              <option value="Mayotte">Mayotte</option> 
              <option value="Mexico">Mexico</option> 
              <option value="Micronesia">Micronesia</option> 
              <option value="Midway Islands">Midway Islands</option> 
              <option value="Moldova">Moldova</option> 
              <option value="Monaco">Monaco</option> 
              <option value="Mongolia">Mongolia</option> 
              <option value="Montserrat">Montserrat</option> 
              <option value="Morocco">Morocco</option> 
              <option value="Mozambique">Mozambique</option> 
              <option value="Namibia">Namibia</option> 
              <option value="Nauru">Nauru</option> 
              <option value="Nepal">Nepal</option> 
              <option value="Netherlands">Netherlands</option> 
              <option value="Netherlands Antilles">Netherlands Antilles</option> 
              <option value="New Caledonia">New Caledonia</option> 
              <option value="New Zealand">New Zealand</option> 
              <option value="Niari">Niari</option> 
              <option value="Nicaragua">Nicaragua</option> 
              <option value="Niger">Niger</option> 
              <option value="Nigeria">Nigeria</option> 
              <option value="Niue">Niue</option> 
              <option value="Norfolk Island">Norfolk Island</option> 
              <option value="Northern Mariana Islands">Northern Mariana Islands</option> 
              <option value="Norway">Norway</option> 
              <option value="Oman">Oman</option> 
              <option value="Pakistan">Pakistan</option> 
              <option value="Palau">Palau</option> 
              <option value="Panama">Panama</option> 
              <option value="Papua New Guinea">Papua New Guinea</option> 
              <option value="Paraguay">Paraguay</option> 
              <option value="Peru">Peru</option> 
              <option value="Philippines">Philippines</option> 
              <option value="Pitcaim Islands">Pitcaim Islands</option> 
              <option value="Plateaux">Plateaux</option> 
              <option value="Poland">Poland</option> 
              <option value="Pool">Pool</option> 
              <option value="Portugal">Portugal</option> 
              <option value="Puerto Rico">Puerto Rico</option> 
              <option value="Qatar">Qatar</option> 
              <option value="Reunion">Reunion</option> 
              <option value="Romainia">Romainia</option> 
              <option value="Russia">Russia</option> 
              <option value="Rwanda">Rwanda</option> 
              <option value="Saint Helena">Saint Helena</option> 
              <option value="Saint Kitts and Nevis">Saint Kitts and Nevis</option> 
              <option value="Saint Lucia">Saint Lucia</option> 
              <option value="Saint Pierre and Miquelon">Saint Pierre and Miquelon</option> 
              <option value="Saint Vincent and the Grenadines">Saint Vincent and the Grenadines</option> 
              <option value="Samoa">Samoa</option> 
              <option value="San Marino">San Marino</option> 
              <option value="Sangha">Sangha</option> 
              <option value="Sao Tome and Principe">Sao Tome and Principe</option> 
              <option value="Saudi Arabia">Saudi Arabia</option> 
              <option value="Scotland">Scotland</option> 
              <option value="Senegal">Senegal</option> 
              <option value="Seychelles">Seychelles</option> 
              <option value="Sierra Leone">Sierra Leone</option> 
              <option value="Singapore">Singapore</option> 
              <option value="Slovakia">Slovakia</option> 
              <option value="Slovenia">Slovenia</option> 
              <option value="Solomon Islands">Solomon Islands</option> 
              <option value="Somalia">Somalia</option> 
              <option value="South Africa">South Africa</option> 
              <option value="South Georgia and South Sandwich Islands">South Georgia and South Sandwich Islands</option> 
              <option value="Spain">Spain</option> 
              <option value="Spratly Islands">Spratly Islands</option> 
              <option value="Sri Lanka">Sri Lanka</option> 
              <option value="Sudan">Sudan</option> 
              <option value="Suriname">Suriname</option> 
              <option value="Svalbard">Svalbard</option> 
              <option value="Swaziland">Swaziland</option> 
              <option value="Sweden">Sweden</option> 
              <option value="Switzerland">Switzerland</option> 
              <option value="Syria">Syria</option> 
              <option value="Taiwan">Taiwan</option> 
              <option value="Tajikistan">Tajikistan</option> 
              <option value="Tanzania">Tanzania</option> 
              <option value="Thailand">Thailand</option> 
              <option value="Tobago">Tobago</option> 
              <option value="Toga">Toga</option> 
              <option value="Tokelau">Tokelau</option> 
              <option value="Tonga">Tonga</option> 
              <option value="Trinidad">Trinidad</option> 
              <option value="Tunisia">Tunisia</option> 
              <option value="Turkey">Turkey</option> 
              <option value="Turkmenistan">Turkmenistan</option> 
              <option value="Tuvalu">Tuvalu</option> 
              <option value="ULL">ULL</option> 
              <option value="Uganda">Uganda</option> 
              <option value="Ukraine">Ukraine</option> 
              <option value="United Arab Emirates">United Arab Emirates</option> 
              <option value="Uruguay">Uruguay</option> 
              <option value="Uzbekistan">Uzbekistan</option> 
              <option value="Vanuatu">Vanuatu</option> 
              <option value="Venezuela">Venezuela</option> 
              <option value="Vietnam">Vietnam</option> 
              <option value="Virgin Islands">Virgin Islands</option> 
              <option value="Wales">Wales</option> 
              <option value="Wallis and Futuna">Wallis and Futuna</option> 
              <option value="West Bank">West Bank</option> 
              <option value="Western Sahara">Western Sahara</option> 
              <option value="Yemen">Yemen</option> 
              <option value="Yugoslavia">Yugoslavia</option> 
              <option value="Zambia">Zambia</option> 
              <option value="Zimbabwe">Zimbabwe</option></select> 
            </li> 
            <li class="string optional" id="institution_address_attributes_post_code_input"><label for="institution_address_attributes_post_code">Post code</label><input id="institution_address_attributes_post_code" name="institution[address_attributes][post_code]" type="text" /></li>  
            <li class="string optional" id="institution_phone_number_input"><label for="institution_phone_number">Phone number</label><input id="institution_phone_number" name="institution[phone_number]" type="text" value="" /></li> 
            <li class="string optional" id="institution_website_input"><label for="institution_website">Website</label><input id="institution_website" name="institution[website]" type="text" /></li> 
            </ol></fieldset>  
            <fieldset class="buttons"><ol><li class="commit"><input class="create" id="institution_submit" name="commit" type="submit" value="Create School" /></li></ol></fieldset> 
            </div>
            </form>
EOS
end
