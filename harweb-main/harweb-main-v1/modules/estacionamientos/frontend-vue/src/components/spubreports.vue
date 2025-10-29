<template>
  <div class="container">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reportes de Estacionamientos Públicos</li>
      </ol>
    </nav>
    <h1>Reportes de Estacionamientos Públicos</h1>
    <div class="mb-3">
      <label for="opc" class="form-label">Tipo de Reporte</label>
      <select v-model="opc" id="opc" class="form-select">
        <option value="1">Por Categoría</option>
        <option value="2">Por Sector</option>
        <option value="3">Por Número de Estacionamiento</option>
        <option value="4">Por Nombre de Estacionamiento</option>
        <option value="5">Por Calle</option>
        <option value="7">Por Zona y Subzona</option>
        <option value="6">Resumen por Categoría y Sector</option>
        <option value="9">Relación de Adeudo y Pago</option>
      </select>
      <button class="btn btn-primary mt-2" @click="fetchReport">Generar Reporte</button>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reportData && opc != 6 && opc != 9">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>#</th>
            <th>Categoría</th>
            <th>Descripción</th>
            <th>Núm. Est.</th>
            <th>Sector</th>
            <th>Zona</th>
            <th>Subzona</th>
            <th>Licencia</th>
            <th>Cve. Cuenta</th>
            <th>Nombre</th>
            <th>Calle</th>
            <th>No. Ext</th>
            <th>Teléfono</th>
            <th>Cupo</th>
            <th>Fecha Alta</th>
            <th>Fecha Inicial</th>
            <th>Fecha Vencimiento</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in reportData" :key="row.id">
            <td>{{ idx+1 }}</td>
            <td>{{ row.categoria }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.numesta }}</td>
            <td>{{ row.nomsector }}</td>
            <td>{{ row.zona }}</td>
            <td>{{ row.subzona }}</td>
            <td>{{ row.numlicencia }}</td>
            <td>{{ row.cvecuenta }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.numext }}</td>
            <td>{{ row.telefono }}</td>
            <td>{{ row.cupo }}</td>
            <td>{{ row.fecha_at }}</td>
            <td>{{ row.fecha_inicial }}</td>
            <td>{{ row.fecha_vencimiento }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="opc == 6 && reportData">
      <h2>Resumen por Categoría y Sector</h2>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Categoría</th>
            <th>Descripción</th>
            <th>Cant. Juarez</th>
            <th>Cap. Juarez</th>
            <th>Cant. Reforma</th>
            <th>Cap. Reforma</th>
            <th>Cant. Libertad</th>
            <th>Cap. Libertad</th>
            <th>Cant. Hidalgo</th>
            <th>Cap. Hidalgo</th>
            <th>Cant. Total</th>
            <th>Cap. Total</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reportData" :key="row.categoria">
            <td>{{ row.categoria }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.cant_j }}</td>
            <td>{{ row.capac_j }}</td>
            <td>{{ row.cant_r }}</td>
            <td>{{ row.capac_r }}</td>
            <td>{{ row.cant_l }}</td>
            <td>{{ row.capac_l }}</td>
            <td>{{ row.cant_h }}</td>
            <td>{{ row.capac_h }}</td>
            <td>{{ row.cant_t }}</td>
            <td>{{ row.capac_t }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="opc == 9 && reportData">
      <h2>Relación de Adeudo y Pago</h2>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Núm. Est.</th>
            <th>Nombre</th>
            <th>Calle</th>
            <th>No. Ext</th>
            <th>Cupo</th>
            <th>Año Adeudo</th>
            <th>Mes Ini Adeudo</th>
            <th>Adeudos Ant.</th>
            <th>Adeudos Act.</th>
            <th>Año Últ. Pago</th>
            <th>Mes Últ. Pago</th>
            <th>Proyectado</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reportData" :key="row.id">
            <td>{{ row.numesta }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.numext }}</td>
            <td>{{ row.cupo }}</td>
            <td>{{ row.axo_adeudo }}</td>
            <td>{{ row.mes_ini_adeudo }}</td>
            <td>{{ row.adeudos_ant }}</td>
            <td>{{ row.adeudos_act }}</td>
            <td>{{ row.axo_ult_pago }}</td>
            <td>{{ row.mes_ult_pago }}</td>
            <td>{{ row.proyectado }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SpubreportsPage',
  data() {
    return {
      opc: 1,
      reportData: null,
      loading: false,
      error: null
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = null;
      this.reportData = null;
      let operation = '';
      let params = {};
      if ([1,2,3,4,5,7].includes(Number(this.opc))) {
        operation = 'spubreports_list';
        params = { opc: Number(this.opc) };
      } else if (Number(this.opc) === 6) {
        operation = 'spubreports_sector_summary';
      } else if (Number(this.opc) === 9) {
        operation = 'spubreports_adeudos';
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              operation,
              params
            }
          })
        });
        const json = await res.json();
        if (json.eResponse && json.eResponse.success) {
          this.reportData = json.eResponse.data;
        } else {
          this.error = json.eResponse && json.eResponse.error ? json.eResponse.error : 'Error desconocido';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.container {
  max-width: 98vw;
}
.table {
  font-size: 0.95em;
}
</style>
