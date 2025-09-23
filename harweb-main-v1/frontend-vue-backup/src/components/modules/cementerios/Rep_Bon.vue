<template>
  <div class="rep-bon-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte Bonificaciones</li>
      </ol>
    </nav>
    <h2>Reporte de Oficios de Bonificación</h2>
    <form @submit.prevent="buscar">
      <div class="form-group row">
        <label class="col-sm-2 col-form-label">Recaudadora</label>
        <div class="col-sm-2">
          <input type="number" min="1" max="9" v-model.number="recaudadora" class="form-control" required />
        </div>
      </div>
      <div class="form-group row">
        <label class="col-sm-2 col-form-label">Tipo</label>
        <div class="col-sm-10">
          <div class="form-check form-check-inline">
            <input class="form-check-input" type="radio" id="pendientes" value="true" v-model="pendientes">
            <label class="form-check-label" for="pendientes">Pendientes</label>
          </div>
          <div class="form-check form-check-inline">
            <input class="form-check-input" type="radio" id="todos" value="false" v-model="pendientes">
            <label class="form-check-label" for="todos">Todos</label>
          </div>
        </div>
      </div>
      <div class="form-group row mt-3">
        <div class="col-sm-12">
          <button type="submit" class="btn btn-primary mr-2">Buscar</button>
          <button type="button" class="btn btn-success mr-2" @click="imprimir" :disabled="!resultados.length">Imprimir</button>
          <button type="button" class="btn btn-secondary" @click="limpiar">Limpiar</button>
        </div>
      </div>
    </form>
    <div v-if="mensaje" class="alert alert-warning mt-3">{{ mensaje }}</div>
    <div v-if="resultados.length" class="table-responsive mt-4">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Oficio</th>
            <th>Año</th>
            <th>Folio Control</th>
            <th>Cem</th>
            <th>Clase</th>
            <th>Clase Alfa</th>
            <th>Sección</th>
            <th>Sección Alfa</th>
            <th>Línea</th>
            <th>Línea Alfa</th>
            <th>Fosa</th>
            <th>Fosa Alfa</th>
            <th>Fecha Oficio</th>
            <th>Importe</th>
            <th>Aplicado</th>
            <th>Pendiente</th>
            <th>Nombre</th>
            <th>Fecha Mov</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in resultados" :key="row.control_bon">
            <td>{{ row.oficio }}</td>
            <td>{{ row.axo }}</td>
            <td>{{ row.control_rcm }}</td>
            <td>{{ row.cementerio }}</td>
            <td>{{ row.clase }}</td>
            <td>{{ row.clase_alfa }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.seccion_alfa }}</td>
            <td>{{ row.linea }}</td>
            <td>{{ row.linea_alfa }}</td>
            <td>{{ row.fosa }}</td>
            <td>{{ row.fosa_alfa }}</td>
            <td>{{ row.fecha_ofic | fecha }}</td>
            <td>{{ row.importe_bonificar | moneda }}</td>
            <td>{{ row.importe_bonificado | moneda }}</td>
            <td>{{ row.importe_resto | moneda }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.fecha_mov | fecha }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="showReport" class="mt-4">
      <h4>Reporte generado (simulado)</h4>
      <div class="alert alert-info">El reporte PDF se generaría aquí o se descargaría.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RepBonPage',
  data() {
    return {
      recaudadora: 1,
      pendientes: 'true',
      resultados: [],
      mensaje: '',
      showReport: false
    }
  },
  methods: {
    async buscar() {
      this.mensaje = '';
      this.showReport = false;
      this.resultados = [];
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'listar',
            recaudadora: this.recaudadora,
            pendientes: this.pendientes === 'true'
          }
        });
        if (resp.data.eResponse.success) {
          this.resultados = resp.data.eResponse.data;
          if (!this.resultados.length) {
            this.mensaje = 'No existen Registros';
          }
        } else {
          this.mensaje = resp.data.eResponse.message;
        }
      } catch (e) {
        this.mensaje = 'Error de comunicación con el servidor';
      }
    },
    async imprimir() {
      this.mensaje = '';
      this.showReport = false;
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'imprimir',
            recaudadora: this.recaudadora,
            pendientes: this.pendientes === 'true'
          }
        });
        if (resp.data.eResponse.success) {
          // Aquí se podría descargar el PDF o mostrarlo
          this.showReport = true;
        } else {
          this.mensaje = resp.data.eResponse.message;
        }
      } catch (e) {
        this.mensaje = 'Error de comunicación con el servidor';
      }
    },
    limpiar() {
      this.recaudadora = 1;
      this.pendientes = 'true';
      this.resultados = [];
      this.mensaje = '';
      this.showReport = false;
    }
  },
  filters: {
    fecha(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    },
    moneda(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
}
</script>

<style scoped>
.rep-bon-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
}
</style>
