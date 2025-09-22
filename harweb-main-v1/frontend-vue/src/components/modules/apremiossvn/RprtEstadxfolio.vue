<template>
  <div class="estad-x-folio-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Estadística de Notificaciones por Folio</li>
      </ol>
    </nav>
    <h2>Estadística de Notificaciones de los Folios</h2>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label for="modu">Módulo</label>
          <select v-model="form.modu" id="modu" class="form-control" required>
            <option value="11">Mercados</option>
            <option value="16">Aseo Contratado</option>
            <option value="24">Estacionamientos Públicos</option>
            <option value="28">Estacionamientos Exclusivos</option>
            <option value="14">Estacionómetros</option>
            <option value="99">Cementerios</option>
          </select>
        </div>
        <div class="form-group col-md-3">
          <label for="rec">Recaudadora</label>
          <input v-model.number="form.rec" type="number" id="rec" class="form-control" required />
        </div>
        <div class="form-group col-md-3">
          <label for="fol1">Folio Inicial</label>
          <input v-model.number="form.fol1" type="number" id="fol1" class="form-control" required />
        </div>
        <div class="form-group col-md-3">
          <label for="fol2">Folio Final</label>
          <input v-model.number="form.fol2" type="number" id="fol2" class="form-control" required />
        </div>
      </div>
      <button type="submit" class="btn btn-primary">Consultar</button>
    </form>

    <div v-if="loading" class="mt-4">
      <span>Cargando reporte...</span>
    </div>

    <div v-if="error" class="alert alert-danger mt-4">{{ error }}</div>

    <div v-if="reportData && reportData.length" class="mt-4">
      <h4>Resultados</h4>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Vigencia</th>
            <th>Practicado</th>
            <th>Folios</th>
            <th>Gastos Pago</th>
            <th>Gastos Gasto</th>
            <th>Adeudo</th>
            <th>Recargos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reportData" :key="row.vigencia + '-' + row.clave_practicado">
            <td>{{ vigenciaStr(row.vigencia) }}</td>
            <td>{{ practStr(row.clave_practicado) }}</td>
            <td>{{ row.cuantos }}</td>
            <td>{{ formatCurrency(row.gastos_pago) }}</td>
            <td>{{ formatCurrency(row.gastos_gasto) }}</td>
            <td>{{ formatCurrency(row.adeudo) }}</td>
            <td>{{ formatCurrency(row.recargos) }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <button class="btn btn-secondary" @click="fetchRecaudadoraZona">Ver Info Oficina</button>
      </div>
      <div v-if="recaudadoraZona" class="mt-3">
        <h5>Datos de Oficina</h5>
        <ul>
          <li><b>Zona:</b> {{ recaudadoraZona.zona }}</li>
          <li><b>Recaudadora:</b> {{ recaudadoraZona.recaudadora }}</li>
          <li><b>Domicilio:</b> {{ recaudadoraZona.domicilio }}</li>
          <li><b>Teléfono:</b> {{ recaudadoraZona.tel }}</li>
          <li><b>Recaudador:</b> {{ recaudadoraZona.recaudador }}</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EstadxFolioPage',
  data() {
    return {
      form: {
        modu: 11,
        rec: '',
        fol1: '',
        fol2: ''
      },
      loading: false,
      error: '',
      reportData: null,
      recaudadoraZona: null
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = null;
      this.recaudadoraZona = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'getEstadxFolioReport',
            params: {
              modu: this.form.modu,
              rec: this.form.rec,
              fol1: this.form.fol1,
              fol2: this.form.fol2
            }
          })
        });
        const data = await response.json();
        if (data.success) {
          this.reportData = data.data;
        } else {
          this.error = data.message || 'Error al consultar el reporte';
        }
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    },
    async fetchRecaudadoraZona() {
      if (!this.form.rec) return;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'getRecaudadoraZona',
            params: { reca: this.form.rec }
          })
        });
        const data = await response.json();
        if (data.success && data.data && data.data.length) {
          this.recaudadoraZona = data.data[0];
        } else {
          this.recaudadoraZona = null;
        }
      } catch (err) {
        this.recaudadoraZona = null;
      }
    },
    vigenciaStr(v) {
      if (v === '1' || v === 1) return 'VIGENTE';
      if (v === '3' || v === 3) return 'CANCELADO';
      return 'PAGADO';
    },
    practStr(p) {
      if (p === 'P') return 'PRACTICADO';
      if (p === 'N') return 'NO LOCALIZADO';
      if (p === 'C') return 'CITADO';
      return 'SIN MOVIMIENTO';
    },
    formatCurrency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.estad-x-folio-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: #f8f9fa;
}
</style>
