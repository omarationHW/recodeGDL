<template>
  <div class="cga-arc-edoex-page">
    <h1>Carga Pagos de SECFIN a MPIO</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Carga Pagos SECFIN</li>
      </ol>
    </nav>
    <div class="row">
      <div class="col-md-4">
        <div class="card mb-3">
          <div class="card-header">Seleccione el Archivo</div>
          <div class="card-body">
            <input type="file" accept=".txt" @change="onFileChange" class="form-control mb-2" />
            <button class="btn btn-primary w-100" @click="parseFile" :disabled="!selectedFile">Descargar Datos</button>
          </div>
        </div>
      </div>
      <div class="col-md-8">
        <div class="card mb-3">
          <div class="card-header">Datos de Remesa</div>
          <div class="card-body">
            <div class="row mb-2">
              <div class="col-2">DEL</div>
              <div class="col-4">
                <input type="date" v-model="fechaInicio" class="form-control" />
              </div>
              <div class="col-2">AL</div>
              <div class="col-4">
                <input type="date" v-model="fechaFin" class="form-control" />
              </div>
            </div>
            <div class="row mb-2">
              <div class="col-3 font-weight-bold">REMESA:</div>
              <div class="col-9">{{ remesaNombre }}</div>
            </div>
            <div class="row mb-2">
              <div class="col-3">Última remesa:</div>
              <div class="col-9">{{ ultimaRemesa }}</div>
            </div>
            <div v-if="statusError" class="alert alert-danger">{{ statusError }}</div>
            <div v-if="datoRegistros" class="alert alert-info">{{ datoRegistros }}</div>
            <div v-if="confirmo" class="alert alert-success">{{ confirmo }}</div>
            <div class="mb-2">
              <button class="btn btn-success mr-2" @click="grabarRegistros" :disabled="!registros.length || grabando || grabado">GRABAR</button>
              <button class="btn btn-warning mr-2" @click="aplicarRemesa" :disabled="!grabado || aplicando || aplicado">APLICAR</button>
              <button class="btn btn-secondary" @click="$router.push('/')">SALIR</button>
            </div>
          </div>
        </div>
        <div class="card">
          <div class="card-header">Vista Previa de Datos</div>
          <div class="card-body p-0">
            <table class="table table-sm table-bordered mb-0">
              <thead>
                <tr>
                  <th>mpio</th>
                  <th>tipoact</th>
                  <th>foliompio</th>
                  <th>placampio</th>
                  <th>fecha pago</th>
                  <th>total</th>
                  <th>fecha alta</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in registros" :key="idx">
                  <td>{{ row.mpio }}</td>
                  <td>{{ row.tipoact }}</td>
                  <td>{{ row.foliompio }}</td>
                  <td>{{ row.placampio }}</td>
                  <td>{{ row.fechapago }}</td>
                  <td>{{ row.total }}</td>
                  <td>{{ row.fechaalta }}</td>
                </tr>
                <tr v-if="!registros.length">
                  <td colspan="7" class="text-center">No hay datos cargados</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'CgaArcEdoExPage',
  data() {
    return {
      selectedFile: null,
      registros: [],
      fechaInicio: '',
      fechaFin: '',
      remesaNombre: '',
      ultimaRemesa: '',
      statusError: '',
      datoRegistros: '',
      confirmo: '',
      grabando: false,
      grabado: false,
      aplicando: false,
      aplicado: false
    };
  },
  created() {
    this.inicializar();
  },
  methods: {
    async inicializar() {
      // Obtener última remesa
      let lastRemesa = 0;
      try {
        let resp = await axios.post('/api/execute', {
          eRequest: { action: 'getLastRemesa' }
        });
        lastRemesa = resp.data.eResponse.data;
        this.ultimaRemesa = lastRemesa;
        this.remesaNombre = 'dti_est_r' + (lastRemesa + 1);
      } catch (e) {
        this.statusError = 'Error obteniendo última remesa';
      }
      // Obtener fechas de la última remesa
      try {
        let resp = await axios.post('/api/execute', {
          eRequest: { action: 'getRemesas' }
        });
        let fechas = resp.data.eResponse.data;
        if (fechas) {
          let fin = new Date(fechas.fecha_fin);
          let nextMonth = new Date(fin.getFullYear(), fin.getMonth() + 1, 1);
          this.fechaInicio = nextMonth.toISOString().substr(0, 10);
          let lastDay = new Date(nextMonth.getFullYear(), nextMonth.getMonth() + 1, 0);
          this.fechaFin = lastDay.toISOString().substr(0, 10);
        } else {
          let today = new Date();
          this.fechaInicio = today.toISOString().substr(0, 10);
          this.fechaFin = today.toISOString().substr(0, 10);
        }
      } catch (e) {
        this.statusError = 'Error obteniendo fechas de remesa';
      }
    },
    onFileChange(e) {
      this.selectedFile = e.target.files[0];
      this.registros = [];
      this.statusError = '';
      this.datoRegistros = '';
      this.confirmo = '';
      this.grabado = false;
      this.aplicado = false;
    },
    parseFile() {
      if (!this.selectedFile) return;
      const reader = new FileReader();
      reader.onload = (e) => {
        const lines = e.target.result.split(/\r?\n/).filter(l => l.trim() !== '');
        this.registros = lines.map(line => {
          const parts = line.split('|');
          return {
            mpio: '113',
            tipoact: 'PN',
            foliompio: parts[2] ? parts[2].trim() : '',
            placampio: parts[3] ? parts[3].trim() : '',
            fechapago: parts[4] ? parts[4].trim() : '',
            total: parts[5] ? parts[5].trim() : '',
            fechaalta: parts[6] ? parts[6].trim() : ''
          };
        });
        this.datoRegistros = `Registros cargados ${this.registros.length}`;
      };
      reader.readAsText(this.selectedFile);
    },
    async grabarRegistros() {
      this.statusError = '';
      this.datoRegistros = '';
      this.confirmo = '';
      this.grabando = true;
      let errores = [];
      let count = 0;
      for (let row of this.registros) {
        try {
          let resp = await axios.post('/api/execute', {
            eRequest: {
              action: 'insertRemesaRecord',
              params: {
                folio: row.foliompio,
                mpio: row.mpio,
                tipoact: row.tipoact,
                placa: row.placampio,
                remesa: this.remesaNombre,
                fecpago: row.fechapago,
                fecalta: row.fechaalta,
                fecremesa: this.fechaFin,
                importe: row.total
              }
            }
          });
          if (!resp.data.eResponse.success) {
            errores.push(`Error en folio ${row.foliompio}`);
          } else {
            count++;
          }
        } catch (e) {
          errores.push(`Error en folio ${row.foliompio}`);
        }
      }
      if (errores.length) {
        this.statusError = 'Error en la carga de folios: ' + errores.join(', ');
      } else {
        // Contar registros
        let resp = await axios.post('/api/execute', {
          eRequest: { action: 'countRemesaRecords', params: { remesa: this.remesaNombre } }
        });
        this.datoRegistros = `Termino grabacion de registros con ${resp.data.eResponse.data}`;
        this.grabado = true;
      }
      this.grabando = false;
    },
    async aplicarRemesa() {
      this.statusError = '';
      this.confirmo = '';
      this.aplicando = true;
      try {
        // Obtener fecha de remesa
        let resp = await axios.post('/api/execute', {
          eRequest: { action: 'getRemesaDate', params: { remesa: this.remesaNombre } }
        });
        let fechaRemesa = resp.data.eResponse.data;
        // Ejecutar stored procedure de aplicación
        let resp2 = await axios.post('/api/execute', {
          eRequest: { action: 'applyRemesa', params: { fecha: fechaRemesa } }
        });
        if (!resp2.data.eResponse.success) {
          this.statusError = 'El procedimiento de aplicación no se ejecutó correctamente';
          this.aplicando = false;
          return;
        }
        // Insertar en bitácora
        let today = new Date().toISOString().substr(0, 10);
        let resp3 = await axios.post('/api/execute', {
          eRequest: {
            action: 'insertBitacora',
            params: {
              fecha_inicio: this.fechaInicio,
              fecha_fin: this.fechaFin,
              fecha: today,
              num_remesa: parseInt(this.ultimaRemesa) + 1,
              cant_reg: this.registros.length
            }
          }
        });
        if (!resp3.data.eResponse.success) {
          this.statusError = 'ERROR al registrar en BITACORA';
        } else {
          this.confirmo = 'Termino la carga de registros';
          this.aplicado = true;
        }
      } catch (e) {
        this.statusError = 'Error en la aplicación de la remesa';
      }
      this.aplicando = false;
    }
  }
};
</script>

<style scoped>
.cga-arc-edoex-page {
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
