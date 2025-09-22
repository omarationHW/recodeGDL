<template>
  <div class="gen-pgos-banorte-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Generación de Pagos Banorte</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4>Generación de Pagos por Banorte</h4>
      </div>
      <div class="card-body">
        <div class="row mb-3">
          <div class="col-md-6">
            <div class="card border-info">
              <div class="card-header bg-info text-white">
                Último y Nuevo Periodo de Pagos Banorte
              </div>
              <div class="card-body">
                <div class="row mb-2">
                  <div class="col-6">
                    <label>Fecha Inicio Anterior:</label>
                    <div class="h5">{{ periodo.fecha_inicio || '--' }}</div>
                  </div>
                  <div class="col-6">
                    <label>Fecha Fin Anterior:</label>
                    <div class="h5">{{ periodo.fecha_fin || '--' }}</div>
                  </div>
                </div>
                <div class="row mb-2">
                  <div class="col-6">
                    <label>Nuevo Inicio:</label>
                    <input type="date" v-model="form.fec_ini" class="form-control" />
                  </div>
                  <div class="col-6">
                    <label>Nuevo Fin:</label>
                    <input type="date" v-model="form.fec_fin" class="form-control" />
                  </div>
                </div>
                <div class="row mt-2">
                  <div class="col-12">
                    <button class="btn btn-success" @click="ejecutarRemesa" :disabled="loading || ejecutado">
                      Ejecutar
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-md-6">
            <div class="mb-3">
              <label class="h5">Registros de Banorte:</label>
              <span class="h4 text-primary">{{ contador }}</span>
            </div>
            <div class="mb-3">
              <label class="h5">Remesa:</label>
              <span class="h4 text-success">{{ remesa }}</span>
            </div>
            <div v-if="ejecutado && contador > 0">
              <button class="btn btn-primary" @click="generarArchivo" :disabled="generandoArchivo">
                Generar Archivo Texto
              </button>
              <div v-if="archivoUrl" class="mt-2">
                <a :href="archivoUrl" target="_blank" class="btn btn-outline-secondary">
                  Descargar Archivo
                </a>
              </div>
            </div>
          </div>
        </div>
        <div v-if="mensaje" class="alert alert-info mt-3">{{ mensaje }}</div>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import dayjs from 'dayjs';

export default {
  name: 'GenPgosBanortePage',
  data() {
    return {
      periodo: {
        fecha_inicio: '',
        fecha_fin: ''
      },
      form: {
        fec_ini: '',
        fec_fin: ''
      },
      remesa: '',
      contador: 0,
      ejecutado: false,
      archivoUrl: '',
      mensaje: '',
      error: '',
      loading: false,
      generandoArchivo: false
    };
  },
  mounted() {
    this.cargarPeriodo();
  },
  methods: {
    async cargarPeriodo() {
      this.loading = true;
      this.error = '';
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            operation: 'get_periodo',
            params: {}
          }
        });
        if (res.data.eResponse.success && res.data.eResponse.data) {
          this.periodo = res.data.eResponse.data;
          // Sugerir nuevo periodo
          const fin = this.periodo.fecha_fin;
          if (fin) {
            const nextDay = dayjs(fin).add(1, 'day').format('YYYY-MM-DD');
            this.form.fec_ini = nextDay;
            this.form.fec_fin = nextDay;
          }
        } else {
          this.error = res.data.eResponse.message || 'No se pudo obtener el periodo.';
        }
      } catch (e) {
        this.error = 'Error al cargar periodo: ' + (e.response?.data?.eResponse?.message || e.message);
      } finally {
        this.loading = false;
      }
    },
    async ejecutarRemesa() {
      this.loading = true;
      this.error = '';
      this.mensaje = '';
      this.ejecutado = false;
      this.remesa = '';
      this.contador = 0;
      this.archivoUrl = '';
      try {
        const axo = dayjs(this.form.fec_ini).year();
        const res = await axios.post('/api/execute', {
          eRequest: {
            operation: 'ejecutar_remesa',
            params: {
              axo,
              fec_ini: this.form.fec_ini,
              fec_fin: this.form.fec_fin
            }
          }
        });
        if (res.data.eResponse.success && res.data.eResponse.data) {
          this.remesa = res.data.eResponse.data.remesa;
          this.contador = res.data.eResponse.data.count;
          this.ejecutado = true;
          this.mensaje = 'Remesa generada correctamente.';
        } else {
          this.error = res.data.eResponse.message || 'No se pudo ejecutar la remesa.';
        }
      } catch (e) {
        this.error = 'Error al ejecutar remesa: ' + (e.response?.data?.eResponse?.message || e.message);
      } finally {
        this.loading = false;
      }
    },
    async generarArchivo() {
      this.generandoArchivo = true;
      this.error = '';
      this.mensaje = '';
      this.archivoUrl = '';
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            operation: 'generar_archivo',
            params: {
              remesa: this.remesa
            }
          }
        });
        if (res.data.eResponse.success && res.data.eResponse.data) {
          this.archivoUrl = res.data.eResponse.data.download_url;
          this.mensaje = 'Archivo generado correctamente.';
        } else {
          this.error = res.data.eResponse.message || 'No se pudo generar el archivo.';
        }
      } catch (e) {
        this.error = 'Error al generar archivo: ' + (e.response?.data?.eResponse?.message || e.message);
      } finally {
        this.generandoArchivo = false;
      }
    }
  }
};
</script>

<style scoped>
.gen-pgos-banorte-page {
  max-width: 900px;
  margin: 0 auto;
}
.card-header h4 {
  margin: 0;
}
</style>
