<template>
  <div class="gen-arc-altas-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Generación de Altas</li>
      </ol>
    </nav>
    <h2 class="mb-4">Generación de Altas</h2>
    <div class="row">
      <div class="col-md-6">
        <div class="card mb-3">
          <div class="card-header">Último y Nuevo Periodo de Altas</div>
          <div class="card-body">
            <div class="mb-2">
              <label>Último Periodo Inicio:</label>
              <span class="badge bg-secondary">{{ periodos.fecha_inicio || '--' }}</span>
            </div>
            <div class="mb-2">
              <label>Último Periodo Fin:</label>
              <span class="badge bg-secondary">{{ periodos.fecha_fin || '--' }}</span>
            </div>
            <div class="mb-2">
              <label for="dtp-inicio">Nuevo Inicio:</label>
              <input type="date" id="dtp-inicio" v-model="form.dtp_inicio" class="form-control" />
            </div>
            <div class="mb-2">
              <label for="dtp-fin">Nuevo Fin:</label>
              <input type="date" id="dtp-fin" v-model="form.dtp_fin" class="form-control" />
            </div>
          </div>
        </div>
      </div>
      <div class="col-md-6">
        <div class="card mb-3">
          <div class="card-body">
            <div class="mb-2">
              <label class="fw-bold">Folios de Alta:</label>
              <span class="fs-5">{{ contadorA }}</span>
            </div>
            <div class="mb-2">
              <label class="fw-bold">Remesa:</label>
              <span class="fs-5">{{ remesa }}</span>
            </div>
            <div class="d-flex gap-2 mt-3">
              <button class="btn btn-primary" @click="ejecutarRemesa" :disabled="loading || ejecutado">Ejecutar</button>
              <button class="btn btn-success" @click="generarArchivo" :disabled="!puedeGenerarArchivo || loading">Generar Archivo</button>
              <button class="btn btn-secondary" @click="cancelar" :disabled="loading">Cancelar</button>
            </div>
            <div v-if="downloadUrl" class="mt-3">
              <a :href="downloadUrl" target="_blank" class="btn btn-outline-info">Descargar Archivo</a>
            </div>
            <div v-if="mensaje" class="alert alert-info mt-3">{{ mensaje }}</div>
            <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'GenArcAltasPage',
  data() {
    return {
      periodos: {
        fecha_inicio: '',
        fecha_fin: ''
      },
      form: {
        dtp_inicio: '',
        dtp_fin: ''
      },
      contadorA: 0,
      remesa: '',
      ejecutado: false,
      puedeGenerarArchivo: false,
      downloadUrl: '',
      mensaje: '',
      error: '',
      loading: false
    };
  },
  mounted() {
    this.cargarPeriodos();
  },
  methods: {
    async cargarPeriodos() {
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            action: 'get_periodos',
            params: {}
          }
        });
        if (res.data.eResponse.success && res.data.eResponse.data) {
          this.periodos = res.data.eResponse.data;
          // Sugerir fechas nuevas
          const fin = this.periodos.fecha_fin;
          if (fin) {
            const nextDay = this.addDays(fin, 1);
            this.form.dtp_inicio = nextDay;
            this.form.dtp_fin = this.getLastDayOfMonth(nextDay);
          }
        } else {
          this.error = 'No se pudo cargar el periodo.';
        }
      } catch (e) {
        this.error = 'Error al cargar periodos.';
      } finally {
        this.loading = false;
      }
    },
    addDays(dateStr, days) {
      const d = new Date(dateStr);
      d.setDate(d.getDate() + days);
      return d.toISOString().slice(0, 10);
    },
    getLastDayOfMonth(dateStr) {
      const d = new Date(dateStr);
      d.setMonth(d.getMonth() + 1);
      d.setDate(0);
      return d.toISOString().slice(0, 10);
    },
    async ejecutarRemesa() {
      this.loading = true;
      this.mensaje = '';
      this.error = '';
      this.downloadUrl = '';
      this.ejecutado = false;
      this.puedeGenerarArchivo = false;
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            action: 'ejecutar_remesa',
            params: {
              fec_ini: this.form.dtp_inicio,
              fec_fin: this.form.dtp_fin
            }
          }
        });
        if (res.data.eResponse.success && res.data.eResponse.data) {
          const data = res.data.eResponse.data;
          if (data.status === 0) {
            this.remesa = data.remesa;
            await this.buscarFoliosRemesa();
            this.ejecutado = true;
            this.mensaje = 'Remesa ejecutada correctamente.';
          } else {
            this.error = 'Hubo errores en el proceso de remesa: ' + (data.obs || '');
          }
        } else {
          this.error = res.data.eResponse.message || 'Error en la ejecución de remesa.';
        }
      } catch (e) {
        this.error = 'Error al ejecutar remesa.';
      } finally {
        this.loading = false;
      }
    },
    async buscarFoliosRemesa() {
      if (!this.remesa) return;
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            action: 'contar_folios',
            params: {
              remesa: this.remesa
            }
          }
        });
        if (res.data.eResponse.success) {
          this.contadorA = res.data.eResponse.data.total;
          this.puedeGenerarArchivo = this.contadorA > 0;
        } else {
          this.error = 'No se pudo contar folios.';
        }
      } catch (e) {
        this.error = 'Error al contar folios.';
      }
    },
    async generarArchivo() {
      this.loading = true;
      this.mensaje = '';
      this.error = '';
      this.downloadUrl = '';
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            action: 'generar_archivo',
            params: {
              remesa: this.remesa
            }
          }
        });
        if (res.data.eResponse.success && res.data.eResponse.data) {
          this.downloadUrl = res.data.eResponse.data.download_url;
          this.mensaje = 'Archivo generado correctamente.';
          this.puedeGenerarArchivo = false;
        } else {
          this.error = res.data.eResponse.message || 'No hubo registros para generar el archivo.';
        }
      } catch (e) {
        this.error = 'Error al generar archivo.';
      } finally {
        this.loading = false;
      }
    },
    cancelar() {
      this.form.dtp_inicio = '';
      this.form.dtp_fin = '';
      this.contadorA = 0;
      this.remesa = '';
      this.ejecutado = false;
      this.puedeGenerarArchivo = false;
      this.downloadUrl = '';
      this.mensaje = '';
      this.error = '';
      this.cargarPeriodos();
    }
  }
};
</script>

<style scoped>
.gen-arc-altas-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  min-height: 250px;
}
</style>
