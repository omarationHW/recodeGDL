<template>
  <div class="altas-conv-div-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Altas de Convenios Diversos</li>
      </ol>
    </nav>
    <h1>Reporte de Altas de Convenios Diversos</h1>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label for="rec">Recaudadora</label>
          <select v-model="form.rec" id="rec" class="form-control" required>
            <option value="ZC1">Zona Centro</option>
            <option value="ZO2">Zona Olímpica</option>
            <option value="ZO3">Zona Oblatos</option>
            <option value="ZM4">Zona Minerva</option>
            <option value="ZC5">Cruz del Sur</option>
          </select>
        </div>
        <div class="form-group col-md-3">
          <label for="fecha1">Fecha desde</label>
          <input type="date" v-model="form.fecha1" id="fecha1" class="form-control" required />
        </div>
        <div class="form-group col-md-3">
          <label for="fecha2">Fecha hasta</label>
          <input type="date" v-model="form.fecha2" id="fecha2" class="form-control" required />
        </div>
        <div class="form-group col-md-3 align-self-end">
          <button type="submit" class="btn btn-primary">Buscar</button>
          <button type="button" class="btn btn-success ml-2" @click="exportExcel" :disabled="loading">Exportar Excel</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="report.length" class="table-responsive mt-3">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Expediente</th>
            <th>Nombre</th>
            <th>Domicilio</th>
            <th>Fecha Alta</th>
            <th>Adeudo Conv.</th>
            <th>Vigencia</th>
            <th>Tipo</th>
            <th>Subtipo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.id_conv_diver">
            <td>{{ row.expediente }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.domicilio }}</td>
            <td>{{ row.fecha_alta }}</td>
            <td class="text-right">{{ row.cantidad_total | currency }}</td>
            <td>{{ row.estado }}</td>
            <td>{{ row.nomtipo }}</td>
            <td>{{ row.nomsubtipo }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-2">
        <strong>Total registros:</strong> {{ report.length }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AltasConvDivPage',
  data() {
    return {
      form: {
        rec: 'ZC1',
        fecha1: '',
        fecha2: ''
      },
      report: [],
      loading: false,
      error: ''
    }
  },
  filters: {
    currency(val) {
      if (!val) return '$0.00';
      return '$' + parseFloat(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'getAltasConvDivReport',
            params: {
              rec: this.form.rec,
              fecha1: this.form.fecha1,
              fecha2: this.form.fecha2
            }
          }
        });
        if (res.data.eResponse.success) {
          this.report = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'Error desconocido';
        }
      } catch (err) {
        this.error = err.response?.data?.eResponse?.message || err.message;
      } finally {
        this.loading = false;
      }
    },
    async exportExcel() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'exportAltasConvDivExcel',
            params: {
              rec: this.form.rec,
              fecha1: this.form.fecha1,
              fecha2: this.form.fecha2
            }
          }
        });
        if (res.data.eResponse.success && res.data.eResponse.data.file_url) {
          window.open(res.data.eResponse.data.file_url, '_blank');
        } else {
          this.error = res.data.eResponse.message || 'No se pudo exportar.';
        }
      } catch (err) {
        this.error = err.response?.data?.eResponse?.message || err.message;
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.altas-conv-div-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  font-size: 0.95rem;
}
</style>
