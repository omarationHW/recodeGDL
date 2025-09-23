<template>
  <div class="gen-arc-diario-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Generación de Archivo Diario</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h3>Generación de Archivo Diario</h3>
      </div>
      <div class="card-body">
        <div class="row mb-4">
          <div class="col-md-6">
            <div class="border p-3 rounded">
              <h5>PERIODO DE LA ÚLTIMA GENERACIÓN DIARIA</h5>
              <div class="form-group">
                <label>Fecha Inicio:</label>
                <span class="ml-2 font-weight-bold">{{ periodoDiario.fecha_inicio || '-' }}</span>
              </div>
              <div class="form-group">
                <label>Fecha Fin:</label>
                <span class="ml-2 font-weight-bold">{{ periodoDiario.fecha_fin || '-' }}</span>
              </div>
              <div class="form-group">
                <label>Nuevo Inicio:</label>
                <input type="date" v-model="form.D_Inicio" class="form-control" />
              </div>
              <div class="form-group">
                <label>Nuevo Fin:</label>
                <input type="date" v-model="form.D_Fin" class="form-control" />
              </div>
            </div>
          </div>
          <div class="col-md-6">
            <div class="border p-3 rounded">
              <h5>PERIODO DE LA ÚLTIMA GENERACIÓN DE ALTAS</h5>
              <div class="form-group">
                <label>Fecha Inicio:</label>
                <span class="ml-2 font-weight-bold">{{ periodoAltas.fecha_inicio || '-' }}</span>
              </div>
              <div class="form-group">
                <label>Fecha Fin:</label>
                <span class="ml-2 font-weight-bold">{{ periodoAltas.fecha_fin || '-' }}</span>
              </div>
            </div>
          </div>
        </div>
        <div class="row mb-3">
          <div class="col-md-12">
            <button class="btn btn-primary mr-2" @click="ejecutarRemesa" :disabled="loading || ejecutado">Ejecutar</button>
            <button class="btn btn-success mr-2" @click="generarArchivo" :disabled="!ejecutado || archivoGenerado || loading">Generar Archivo</button>
            <button class="btn btn-secondary" @click="volver">Salir</button>
          </div>
        </div>
        <div v-if="mensaje" class="alert" :class="{'alert-success': success, 'alert-danger': !success}">
          {{ mensaje }}
        </div>
        <div v-if="ejecutado" class="mt-3">
          <h5>Resumen de Remesa</h5>
          <div class="row">
            <div class="col-md-4">
              <strong>Remesa:</strong> {{ remesa.remesa }}
            </div>
            <div class="col-md-4">
              <strong>Obs:</strong> {{ remesa.obs }}
            </div>
            <div class="col-md-4">
              <strong>Folios PN:</strong> {{ foliosPN }} | <strong>Folios C:</strong> {{ foliosC }} | <strong>Folios PR:</strong> {{ foliosPR }}
            </div>
          </div>
        </div>
        <div v-if="archivoGenerado" class="mt-3">
          <a :href="archivoUrl" class="btn btn-outline-info" download>Descargar Archivo de Remesa</a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import dayjs from 'dayjs';

export default {
  name: 'GenArcDiarioPage',
  data() {
    return {
      periodoDiario: {},
      periodoAltas: {},
      form: {
        D_Inicio: '',
        D_Fin: ''
      },
      remesa: {},
      foliosPN: 0,
      foliosC: 0,
      foliosPR: 0,
      ejecutado: false,
      archivoGenerado: false,
      archivoUrl: '',
      mensaje: '',
      success: true,
      loading: false
    };
  },
  created() {
    this.cargarPeriodos();
  },
  methods: {
    async cargarPeriodos() {
      try {
        let res1 = await axios.post('/api/execute', { eRequest: 'get_periodo_diario' });
        if (res1.data.eResponse.status === 'ok' && res1.data.eResponse.data) {
          this.periodoDiario = res1.data.eResponse.data;
          this.form.D_Inicio = dayjs(this.periodoDiario.fecha_fin).add(1, 'day').format('YYYY-MM-DD');
          this.form.D_Fin = dayjs().format('YYYY-MM-DD');
        }
        let res2 = await axios.post('/api/execute', { eRequest: 'get_periodo_altas' });
        if (res2.data.eResponse.status === 'ok' && res2.data.eResponse.data) {
          this.periodoAltas = res2.data.eResponse.data;
        }
      } catch (e) {
        this.mensaje = 'Error al cargar periodos';
        this.success = false;
      }
    },
    async ejecutarRemesa() {
      this.loading = true;
      this.mensaje = '';
      this.success = true;
      this.ejecutado = false;
      this.archivoGenerado = false;
      try {
        const p_Axo = dayjs(this.form.D_Inicio).year();
        const p_Fec_Ini = this.form.D_Inicio;
        const p_Fec_Fin = this.form.D_Fin;
        const p_Fec_A_Fin = this.periodoAltas.fecha_fin;
        let res = await axios.post('/api/execute', {
          eRequest: 'ejecutar_remesa',
          params: { p_Axo, p_Fec_Ini, p_Fec_Fin, p_Fec_A_Fin }
        });
        if (res.data.eResponse.status === 'ok' && res.data.eResponse.data) {
          const data = res.data.eResponse.data;
          if (data.status === 0) {
            this.remesa = data;
            await this.buscarFolios();
            this.ejecutado = true;
            this.mensaje = 'Remesa ejecutada correctamente';
            this.success = true;
          } else {
            this.mensaje = 'Hubo errores en el proceso sp14_remesa';
            this.success = false;
          }
        } else {
          this.mensaje = res.data.eResponse.message || 'Error en la ejecución';
          this.success = false;
        }
      } catch (e) {
        this.mensaje = 'Error en la ejecución: ' + (e.response?.data?.eResponse?.message || e.message);
        this.success = false;
      }
      this.loading = false;
    },
    async buscarFolios() {
      this.foliosPN = await this.buscarFoliosTipo('PN');
      this.foliosC = await this.buscarFoliosTipo('C');
      this.foliosPR = await this.buscarFoliosTipo('PR');
    },
    async buscarFoliosTipo(tipo) {
      try {
        let res = await axios.post('/api/execute', {
          eRequest: 'buscar_folios_remesa',
          params: { remesa: this.remesa.remesa, tipoact: tipo }
        });
        if (res.data.eResponse.status === 'ok' && res.data.eResponse.data) {
          return res.data.eResponse.data.count || 0;
        }
      } catch (e) {}
      return 0;
    },
    async generarArchivo() {
      this.loading = true;
      this.mensaje = '';
      this.success = true;
      try {
        let res = await axios.post('/api/execute', {
          eRequest: 'generar_archivo_remesa',
          params: { remesa: this.remesa.remesa }
        });
        if (res.data.eResponse.status === 'ok' && res.data.eResponse.data) {
          this.archivoUrl = res.data.eResponse.data.download_url;
          this.archivoGenerado = true;
          this.mensaje = 'Archivo generado correctamente';
          this.success = true;
        } else {
          this.mensaje = res.data.eResponse.message || 'No hubo registros para generar el archivo de texto, intenta con otro';
          this.success = false;
        }
      } catch (e) {
        this.mensaje = 'Error al generar archivo: ' + (e.response?.data?.eResponse?.message || e.message);
        this.success = false;
      }
      this.loading = false;
    },
    volver() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.gen-arc-diario-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  margin-top: 20px;
}
</style>
