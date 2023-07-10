source ../plafrim_env.sh

# if [ $1 == "MGS" ]; then
#     # Recompile to ensure the compiled version is (1) up-to-date (2) specific to the arch of the current job
#     rm -rf ../pola/gs_${ARCH}
#     cp -r ../pola/gs ../pola/gs_${ARCH}
#     ( cd ../pola/gs_${ARCH}/; make clean && make ) 1>&2
# elif [ $1 == "A2V" ]; then
#     rm -rf ../pola/hh_${ARCH}_A2V
#     cp -r ../pola/hh ../pola/hh_${ARCH}_A2V
#     ( cd ../pola/hh_${ARCH}_A2V/; make clean && make main_a2v__time.exe ) 1>&2
# elif [ $1 == "V2Q" ]; then
#     rm -rf ../pola/hh_${ARCH}_V2Q
#     cp -r ../pola/hh ../pola/hh_${ARCH}_V2Q
#     ( cd ../pola/hh_${ARCH}_V2Q/; make clean && make main_v2q__time.exe ) 1>&2
# fi

if [ $1 == "MGS" ]; then
    python3 ../run_all.py --algo mgs --exec ../../pola/gs_${ARCH}/main_qr__time.exe --mvalues 5000 --nvalues $(seq 1 100) --batch 8 -- ${OTHER:=}
elif [ $1 == "A2V" ]; then
    python3 ../run_all.py --algo a2v --exec ../../pola/hh_${ARCH}_A2V/main_a2v__time.exe  --mvalues 5000 --nvalues $(seq 1 100) --batch 8 -- ${OTHER:=}
elif [ $1 == "V2Q" ]; then
    python3 ../run_all.py --algo v2q --exec ../../pola/hh_${ARCH}_V2Q/main_v2q__time.exe  --mvalues 5000 --nvalues $(seq 1 100) --batch 8 -- ${OTHER:=}
else
    echo "Unknown algorithm" $1
fi
