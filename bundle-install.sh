#!/usr/local/bin/bash

executeCommand () {
	local cmd=$1
	echo "$ $cmd"
    eval $cmd
	echo
}

function confirmYesOrNo {
	MSG=$1
	while :
	do
		echo -en "${MSG} [Yes/No]: "
		read line
		case $line in
		[yY][eE][sS]) return 1;;
		[nN][oO]) return 0 ;;
 		esac
	done
}

function confirmCommand () {
    msg=$1
	id_start=$2
	id_end=$3
	re="^[0-9]+$"
	while :
	do
		echo -en "${msg}"
		read input
		if [[ ${input} =~ $re ]] ; then
		    if ((${id_start} <= ${input})) && ((${input} <= ${id_end})); then
                return ${input}
            fi
		else
		    echo -e "\nPlease input valid id."
		fi
	done
}

function split () {
    local str=$1
    local delim=$2
    local -a array=()
    IFS=$delim read -ra arr <<< $str
    echo $arr
    # echo ${arr[@]}
}


function boolean () {
    case $1 in
        true) echo true ;;
        *) echo false ;;
    esac
}

########################
# Variable
########################

command_items=(
"install:bundle install --clean --path .bundle:Install gems"
"update:bundle update:Update gems"
)
command_items_id_start=0
command_items_id_end=$((${#command_items[@]} - 1))

########################
# Main
########################

# Print commands
echo
echo "Select fastlane command"
echo

for i in "${!command_items[@]}"; do
    command_item=${command_items[$i]}

    IFS=':' read -ra ret <<< "$command_item"

    id=${ret[0]}
    command=${ret[1]}
    description=${ret[2]}

    printf "%4s $ %-50s %-60s" "[${i}]" "${command}" "${description}"
    echo
done

# Print input dialog
msg="\nInput id to execute. [${command_items_id_start}-${command_items_id_end}]: "
confirmCommand "${msg}" ${command_items_id_start} ${command_items_id_end}
index_to_execute=$?

selected_command_item=${command_items[$index_to_execute]}
IFS=':' read -ra selected_command_item <<< "$selected_command_item"
selected_command_id=${selected_command_item[0]}
selected_command=${selected_command_item[1]}

# Execute command
echo
executeCommand "${selected_command}"

echo
echo "All done."
echo
