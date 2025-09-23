<template>
  <div class="gadeudos-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Estado de Cuenta</li>
      </ol>
    </nav>
    <h2>Estado de Cuenta</h2>
    <div class="card mb-3">
      <div class="card-body">
        <div class="row mb-2">
          <div class="col-md-4">
            <label>Tipo de búsqueda</label>
            <select v-model="form.tipoBusqueda" class="form-control">
              <option value="expediente">Por Expediente</option>
              <option value="local">Por Local</option>
            </select>
          </div>
          <div class="col-md-4" v-if="form.tipoBusqueda === 'expediente'">
            <label>Número de Expediente</label>
            <input v-model="form.numExpediente" class="form-control" maxlength="10" />
          </div>
          <div class="col-md-2" v-if="form.tipoBusqueda === 'local'">
            <label>Número de Local</label>
            <input v-model="form.numLocal" class="form-control" maxlength="3" />
          </div>
          <div class="col-md-2" v-if="form.tipoBusqueda === 'local'">
            <label>Letra</label>
            <input v-model="form.letraLocal" class="form-control" maxlength="2" />
          </div>
        </div>
        <div class="row mb-2">
          <div class="col-md-4">
            <label>Periodo</label>
            <select v-model="form.periodo" class="form-control" @change="onPeriodoChange">
              <option value="vencidos">Periodos Vencidos</option>
              <option value="otro">Otro Periodo</option>
            </select>
          </div>
          <div class="col-md-2" v-if="form.periodo === 'otro'">
            <label>Año</label>
            <input v-model="form.anio" class="form-control" maxlength="4" />
          </div>
          <div class="col-md-2" v-if="form.periodo === 'otro'">
            <label>Mes</label>
            <select v-model="form.mes" class="form-control">
              <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.text }}</option>
            </select>
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-md-12">
            <button class="btn btn-primary mr-2" @click="buscar">Buscar</button>
            <button class="btn btn-success mr-2" :disabled="!adeudo" @click="imprimir('concentrado')">Imprimir Concentrado</button>
            <button class="btn btn-info" :disabled="!adeudo" @click="imprimir('detalle')">Imprimir Detalle</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="adeudo">
      <h4>Datos del Contribuyente</h4>
      <table class="table table-bordered">
        <tr><th>Control</th><td>{{ adeudo.control }}</td><th>Concesionario</th><td>{{ adeudo.concesionario }}</td></tr>
        <tr><th>Ubicación</th><td>{{ adeudo.ubicacion }}</td><th>Superficie</th><td>{{ adeudo.superficie }}</td></tr>
        <tr><th>Licencia</th><td>{{ adeudo.licencia }}</td><th>Oficina</th><td>{{ adeudo.recaudadora }}</td></tr>
        <tr><th>Sector</th><td>{{ adeudo.sector }}</td><th>Zona</th><td>{{ adeudo.zona }}</td></tr>
        <tr><th>Inicio Obligación</th><td>{{ adeudo.fechainicio }}</td><th>Unidades</th><td>{{ adeudo.unidades }}</td></tr>
      </table>
      <h4>Detalle de Adeudos</h4>
      <table class="table table-striped">
        <thead>
          <tr>
            <th>Concepto</th>
            <th>Adeudo</th>
            <th>Recargos</th>
            <th>Multas</th>
            <th>Actualización</th>
            <th>Gastos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in detalle" :key="item.concepto">
            <td>{{ item.concepto }}</td>
            <td>{{ money(item.importe_adeudos) }}</td>
            <td>{{ money(item.importe_recargos) }}</td>
            <td>{{ money(item.importe_multas) }}</td>
            <td>{{ money(item.importe_actualizacion) }}</td>
            <td>{{ money(item.importe_gastos) }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr class="font-weight-bold">
            <td>Total</td>
            <td>{{ money(total('importe_adeudos')) }}</td>
            <td>{{ money(total('importe_recargos')) }}</td>
            <td>{{ money(total('importe_multas')) }}</td>
            <td>{{ money(total('importe_actualizacion')) }}</td>
            <td>{{ money(total('importe_gastos')) }}</td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'GAdeudosPage',
  data() {
    return {
      form: {
        tipoBusqueda: 'expediente',
        numExpediente: '',
        numLocal: '',
        letraLocal: '',
        periodo: 'vencidos',
        anio: new Date().getFullYear().toString(),
        mes: (new Date().getMonth() + 1).toString().padStart(2, '0')
      },
      meses: [
        { value: '01', text: 'Enero' }, { value: '02', text: 'Febrero' },
        { value: '03', text: 'Marzo' }, { value: '04', text: 'Abril' },
        { value: '05', text: 'Mayo' }, { value: '06', text: 'Junio' },
        { value: '07', text: 'Julio' }, { value: '08', text: 'Agosto' },
        { value: '09', text: 'Septiembre' }, { value: '10', text: 'Octubre' },
        { value: '11', text: 'Noviembre' }, { value: '12', text: 'Diciembre' }
      ],
      loading: false,
      error: '',
      adeudo: null,
      detalle: []
    }
  },
  methods: {
    onPeriodoChange() {
      if (this.form.periodo === 'vencidos') {
        this.form.anio = new Date().getFullYear().toString();
        this.form.mes = (new Date().getMonth() + 1).toString().padStart(2, '0');
      } else {
        this.form.anio = '';
        this.form.mes = '01';
      }
    },
    async buscar() {
      this.error = '';
      this.adeudo = null;
      this.detalle = [];
      let par_tab = '3'; // Ejemplo: tabla 3 (Rastro)
      let par_control = '';
      if (this.form.tipoBusqueda === 'expediente') {
        if (!this.form.numExpediente) {
          this.error = 'Ingrese el número de expediente';
          return;
        }
        par_control = 'R' + this.form.numExpediente; // Ejemplo: abreviatura + número
      } else {
        if (!this.form.numLocal) {
          this.error = 'Ingrese el número de local';
          return;
        }
        par_control = this.form.numLocal;
        if (this.form.letraLocal) par_control += '-' + this.form.letraLocal;
      }
      this.loading = true;
      try {
        // Buscar cabecera
        let res = await this.$axios.post('/api/execute', {
          action: 'GAdeudos.buscar',
          params: { par_tab, par_control }
        });
        if (!res.data.success || !res.data.data.length) {
          this.error = 'No existe registro con ese dato';
          this.loading = false;
          return;
        }
        this.adeudo = res.data.data[0];
        // Buscar detalle
        let par_rep = (this.form.periodo === 'vencidos') ? 'V' : 'A';
        let par_fecha = this.form.anio + '-' + this.form.mes;
        let resDet = await this.$axios.post('/api/execute', {
          action: 'GAdeudos.detalle',
          params: {
            par_tab,
            par_control: this.adeudo.control,
            par_rep,
            par_fecha
          }
        });
        this.detalle = resDet.data.data;
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      }
      this.loading = false;
    },
    imprimir(tipo) {
      // tipo: concentrado | detalle
      // Simulación: abre PDF en nueva ventana (en real, se puede usar jsPDF o similar)
      alert('Funcionalidad de impresión: ' + tipo + ' (simulada)');
    },
    money(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    },
    total(field) {
      return this.detalle.reduce((sum, row) => sum + Number(row[field] || 0), 0);
    }
  }
}
</script>

<style scoped>
.gadeudos-page {
  max-width: 900px;
  margin: 0 auto;
}
.breadcrumb {
  background: #f8f9fa;
}
</style>
