#!/bin/sh

function add_config {
    crudini --set $1 $2 $3 $4
}
