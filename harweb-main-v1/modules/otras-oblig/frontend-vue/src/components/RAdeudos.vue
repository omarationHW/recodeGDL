<template>
  <div class="container py-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Estado de Cuenta (RAdeudos)</li>
      </ol>
    </nav>
    <h2 class="mb-4">Estado de Cuenta</h2>
    <div class="card mb-3">
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-3">
              <label for="numero" class="form-label">Número de Local</label>
              <input v-model="numero" id="numero" maxlength="3" class="form-control" required pattern="\\d+" @keypress="onlyNumber($event, 3)" />
            </div>
            <div class="col-md-3">
              <label for="letra" class="form-label">Letra</label>
              <input v-model="letra" id="letra" maxlength="1" class="form-control text-uppercase" style="text-transform:uppercase" />
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-4">
              <label for="vigencia" class="form-label">Periodo</label>
              <select v-model="vigencia" id="vigencia" class="form-select" @change="onVigenciaChange">
                <option value="vencidos">Periodos Vencidos</option>
                <option value="otro">Otro Periodo</option>
              </select>
            </div>
            <div class="col-md-2" v-if="vigencia === 'otro'">
              <label for="aso" class="form-label">Año</label>
              <input v-model="aso" id="aso" maxlength="4" class="form-control" required pattern="\\d{4}" @keypress="onlyNumber($event, 4)" />
            </div>
            <div class="col-md-2" v-if="vigencia === 'otro'">
              <label for="mes" class="form-label">Mes</label>
              <select v-model="mes" id="mes" class="form-select">
                <option v-for="m in meses" :key="m" :value="m">{{ m }}</option>
              </select>
            </div>
          </div>
          <div class="row mt-3">
            <div class="col-md-6">
              <button type="submit" class="btn btn-primary me-2">Consultar</button>
              <button type="button" class="btn btn-secondary" @click="onSalir">Salir</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="contrato">
      <h5>Datos del Local</h5>
      <table class="table table-bordered table-sm">
        <tr><th>Control</th><td>{{ contrato.control }}</td></tr>
        <tr><th>Concesionario</th><td>{{ contrato.concesionario }}</td></tr>
        <tr><th>Ubicación</th><td>{{ contrato.ubicacion }}</td></tr>
        <tr><th>Superficie</th><td>{{ contrato.superficie }}</td></tr>
        <tr><th>Fecha Inicio</th><td>{{ contrato.fecha_inicio }}</td></tr>
        <tr><th>Fecha Fin</th><td>{{ contrato.fecha_fin }}</td></tr>
        <tr><th>Ofna</th><td>{{ contrato.id_recaudadora }}</td></tr>
        <tr><th>Sector</th><td>{{ contrato.sector }}</td></tr>
        <tr><th>Zona</th><td>{{ contrato.id_zona }}</td></tr>
        <tr><th>Licencia</th><td>{{ contrato.licencia }}</td></tr>
      </table>
    </div>
    <div v-if="adeudos && adeudos.length">
      <h5 class="mt-4">Adeudos</h5>
      <table class="table table-striped table-bordered table-sm">
        <thead>
          <tr>
            <th>Descripción</th>
            <th>Adeudo</th>
            <th>Recargo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in adeudos" :key="idx">
            <td>{{ row.expression || row["(expression)"] }}</td>
            <td class="text-end">{{ currency(row.expression_1 || row["(expression)_1"] || row.expression_2 || row["(expression)_2"]) }}</td>
            <td class="text-end">{{ currency(row.expression_2 || row["(expression)_2"] || row.expression_3 || row["(expression)_3"]) }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr class="fw-bold">
            <td class="text-end">TOTAL</td>
            <td class="text-end">{{ currency(totalAdeudo) }}</td>
            <td class="text-end">{{ currency(totalRecargo) }}</td>
          </tr>
          <tr class="fw-bold">
            <td class="text-end">TOTAL CONTRATO</td>
            <td colspan="2" class="text-end">{{ currency(totalAdeudo + totalRecargo) }}</td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RAdeudosPage',
  data() {
    const now = new Date();
    return {
      numero: '',
      letra: '',
      vigencia: 'vencidos',
      aso: String(now.getFullYear()),
      mes: ('0' + (now.getMonth() + 1)).slice(-2),
      meses: ['01','02','03','04','05','06','07','08','09','10','11','12'],
      contrato: null,
      adeudos: [],
      error: '',
      loading: false
    };
  },
  computed: {
    totalAdeudo() {
      if (!this.adeudos || !this.adeudos.length) return 0;
      // Try both field names for compatibility
      return this.adeudos.reduce((sum, row) => {
        let val = row.expression_1 || row['(expression)_1'] || row.expression_2 || row['(expression)_2'] || 0;
        return sum + (parseFloat(val) || 0);
      }, 0);
    },
    totalRecargo() {
      if (!this.adeudos || !this.adeudos.length) return 0;
      return this.adeudos.reduce((sum, row) => {
        let val = row.expression_2 || row['(expression)_2'] || row.expression_3 || row['(expression)_3'] || 0;
        return sum + (parseFloat(val) || 0);
      }, 0);
    }
  },
  methods: {
    onlyNumber(evt, maxlen) {
      const key = evt.key;
      if (!/\d/.test(key) || (evt.target.value.length >= maxlen && !evt.target.selectionEnd)) {
        evt.preventDefault();
      }
    },
    currency(val) {
      if (val === undefined || val === null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    onVigenciaChange() {
      if (this.vigencia === 'vencidos') {
        const now = new Date();
        this.aso = String(now.getFullYear());
        this.mes = ('0' + (now.getMonth() + 1)).slice(-2);
      } else {
        this.aso = '';
        this.mes = '01';
      }
    },
    async onSubmit() {
      this.error = '';
      this.contrato = null;
      this.adeudos = [];
      if (!this.numero || this.numero === '0') {
        this.error = 'Falta el dato del NÚMERO DE LOCAL, intentalo de nuevo';
        return;
      }
      if (this.vigencia === 'otro' && (!this.aso || this.aso === '0')) {
        this.error = 'Falta el dato del AÑO a consultar, intentalo de nuevo';
        return;
      }
      this.loading = true;
      try {
        // 1. Buscar contrato
        const control = this.numero + '-' + (this.letra || '');
        let resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'RAdeudos.BuscaCont',
            params: { cve: '3', control }
          })
        });
        let data = await resp.json();
        if (!data.success || !data.data || !data.data.length) {
          this.error = 'No existe LOCAL con este dato, intentalo de nuevo';
          this.loading = false;
          return;
        }
        this.contrato = data.data[0];
        // 2. Buscar adeudos
        let par_Rep = this.vigencia === 'vencidos' ? 'V' : 'A';
        let par_Fecha = this.aso + '-' + this.mes;
        let adeudosReq = this.vigencia === 'vencidos' ? 'RAdeudos.BuscaAdeudos01' : 'RAdeudos.BuscaAdeudos02';
        resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: adeudosReq,
            params: {
              par_Control: this.contrato.id_34_datos,
              par_Rep,
              par_Fecha
            }
          })
        });
        data = await resp.json();
        if (!data.success) {
          this.error = data.message || 'Error al consultar adeudos';
          this.loading = false;
          return;
        }
        this.adeudos = data.data || [];
      } catch (e) {
        this.error = e.message || 'Error de comunicación';
      } finally {
        this.loading = false;
      }
    },
    onSalir() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.table-sm th, .table-sm td { font-size: 0.95em; }
</style>
