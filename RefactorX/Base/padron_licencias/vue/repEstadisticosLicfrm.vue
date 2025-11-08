<template>
  <div class="estadisticos-lic-page">
    <h1>Reportes Estadísticos de Licencias</h1>
    <div class="form-section">
      <el-form :model="form" label-width="180px">
        <el-form-item label="Seleccione el reporte">
          <el-radio-group v-model="form.reporte">
            <el-radio :label="'rango'">Licencias dadas de alta en un rango de tiempo</el-radio>
            <el-radio :label="'giro_zona'">Licencias por giro y zona</el-radio>
            <el-radio :label="'giros_reglamentados_zona'">Giros reglamentados por zona</el-radio>
            <el-radio :label="'reglamentadas_rango'">Licencias reglamentadas dadas de alta en un rango de tiempo</el-radio>
            <el-radio :label="'pagos_rango'">Pagos de licencias en un rango de tiempo</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item v-if="requiresFechas" label="Fecha inicial">
          <el-date-picker v-model="form.fecha1" type="date" placeholder="Seleccione fecha inicial" />
        </el-form-item>
        <el-form-item v-if="requiresFechas" label="Fecha final">
          <el-date-picker v-model="form.fecha2" type="date" placeholder="Seleccione fecha final" />
        </el-form-item>
        <el-form-item v-if="requiresClasificacion" label="Clasificación">
          <el-select v-model="form.clasificacion" placeholder="Seleccione">
            <el-option label="Ambas" value="" />
            <el-option label="Solo C" value="C" />
            <el-option label="Solo D" value="D" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="consultar">Consultar</el-button>
        </el-form-item>
      </el-form>
    </div>
    <div class="result-section" v-if="result && result.length">
      <el-table :data="result" style="width: 100%">
        <el-table-column v-for="col in columns" :key="col.prop" :prop="col.prop" :label="col.label" />
      </el-table>
    </div>
    <el-alert v-if="error" type="error" :title="error" show-icon />
  </div>
</template>

<script>
export default {
  name: 'EstadisticosLicPage',
  data() {
    return {
      form: {
        reporte: 'rango',
        fecha1: '',
        fecha2: '',
        clasificacion: ''
      },
      result: [],
      error: '',
      columns: []
    };
  },
  computed: {
    requiresFechas() {
      return [
        'rango',
        'reglamentadas_rango',
        'pagos_rango'
      ].includes(this.form.reporte);
    },
    requiresClasificacion() {
      return [
        'giros_reglamentados_zona',
        'reglamentadas_rango'
      ].includes(this.form.reporte);
    }
  },
  methods: {
    async consultar() {
      this.error = '';
      this.result = [];
      let action = '';
      let params = {};
      switch (this.form.reporte) {
        case 'rango':
          action = 'reporte_licencias_rango';
          params = { fecha1: this.form.fecha1, fecha2: this.form.fecha2 };
          break;
        case 'giro_zona':
          action = 'reporte_licencias_giro_zona';
          break;
        case 'giros_reglamentados_zona':
          action = 'reporte_giros_reglamentados_zona';
          params = { clasificacion: this.form.clasificacion };
          break;
        case 'reglamentadas_rango':
          action = 'reporte_licencias_reglamentadas_rango';
          params = { fecha1: this.form.fecha1, fecha2: this.form.fecha2, clasificacion: this.form.clasificacion };
          break;
        case 'pagos_rango':
          action = 'reporte_pagos_licencias_rango';
          params = { fecha1: this.form.fecha1, fecha2: this.form.fecha2 };
          break;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action,
            params
          }
        });
        if (res.data.eResponse.success) {
          this.result = res.data.eResponse.data;
          if (this.result.length > 0) {
            this.columns = Object.keys(this.result[0]).map(k => ({ prop: k, label: k.toUpperCase() }));
          }
        } else {
          this.error = res.data.eResponse.error || 'Error desconocido';
        }
      } catch (e) {
        this.error = e.response?.data?.eResponse?.error || e.message;
      }
    }
  }
};
</script>

<style scoped>
.estadisticos-lic-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-section {
  margin-bottom: 2rem;
}
.result-section {
  margin-top: 2rem;
}
</style>
