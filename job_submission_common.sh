source ./plafrim_env.sh

# Recompile to ensure the compiled version is (1) up-to-date (2) specific to the arch of the current job
rm -rf ../pola/gs_${ARCH}
cp -r ../pola/gs ../pola/gs_${ARCH}
( cd ../pola/gs_${ARCH}/; make clean && make ) 1>&2

rm -rf ../pola/hh_${ARCH}
cp -r ../pola/hh ../pola/hh_${ARCH}
( cd ../pola/hh_${ARCH}/; make clean && make ) 1>&2

python3 ./run_all.py --algo mgs --exec ../pola/gs_${ARCH}/ -- ${OTHER:=}
python3 ./run_all.py --algo a2v --exec ../pola/hh_${ARCH}/main_a2v__time.exe -- ${OTHER}
python3 ./run_all.py --algo v2q --exec ../pola/hh_${ARCH}/main_v2q__time.exe -- ${OTHER}
