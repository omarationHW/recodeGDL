<template>
  <div class="consulta-predial-page">
    <h1>Consulta Predial</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Consulta Predial
    </div>
    <form @submit.prevent="buscarCuenta">
      <div class="form-row">
        <label>Recaudadora:</label>
        <input v-model="form.recaud" maxlength="3" required />
        <label>Tipo (U/R):</label>
        <input v-model="form.urbrus" maxlength="1" required />
        <label>Cuenta:</label>
        <input v-model="form.cuenta" maxlength="8" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="cuenta">
      <h2>Datos de la Cuenta</h2>
      <table class="table table-sm">
        <tr><th>Clave Catastral</th><td>{{ cuenta.cvecatnva }}</td></tr>
        <tr><th>Subpredio</th><td>{{ cuenta.subpredio }}</td></tr>
        <tr><th>Vigente</th><td>{{ cuenta.vigente }}</td></tr>
        <tr><th>Clave UTM</th><td>{{ cuenta.claveutm }}</td></tr>
        <tr><th>Cuenta</th><td>{{ cuenta.cuenta }}</td></tr>
        <tr><th>Recaudadora</th><td>{{ cuenta.recaud }}</td></tr>
        <tr><th>Tipo</th><td>{{ cuenta.urbrus }}</td></tr>
      </table>
      <button @click="verGrafico">Ver Ubicación Cartográfica</button>
    </div>
    <div v-if="saldos">
      <h2>Saldos por Año</h2>
      <table class="table table-bordered">
        <thead>
          <tr><th>Año</th><th>Impuesto</th><th>Recargos</th><th>Saldo Total</th></tr>
        </thead>
        <tbody>
          <tr v-for="row in saldos" :key="row.anio">
            <td>{{ row.anio }}</td>
            <td>{{ row.impuesto }}</td>
            <td>{{ row.recargos }}</td>
            <td>{{ row.saldototal }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="recibos">
      <h2>Recibos</h2>
      <table class="table table-bordered">
        <thead>
          <tr><th>Rec</th><th>Caja</th><th>Folio</th><th>Concepto</th><th>Fecha</th><th>Hora</th><th>Importe</th></tr>
        </thead>
        <tbody>
          <tr v-for="row in recibos" :key="row.cvepago">
            <td>{{ row.recaud }}</td>
            <td>{{ row.caja }}</td>
            <td>{{ row.folio }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.fecha }}</td>
            <td>{{ row.hora }}</td>
            <td>{{ row.importe }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="requerimientos">
      <h2>Requerimientos</h2>
      <table class="table table-bordered">
        <thead>
          <tr><th>Año</th><th>Folio</th><th>Impuesto</th><th>Recargos</th><th>Gastos</th><th>Total</th></tr>
        </thead>
        <tbody>
          <tr v-for="row in requerimientos" :key="row.folioreq">
            <td>{{ row.axoreq }}</td>
            <td>{{ row.folioreq }}</td>
            <td>{{ row.impuesto }}</td>
            <td>{{ row.recargos }}</td>
            <td>{{ row.gastos }}</td>
            <td>{{ row.total }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="regimen">
      <h2>Régimen de Propiedad</h2>
      <table class="table table-bordered">
        <thead>
          <tr><th>Encabeza</th><th>%</th><th>Calidad</th><th>Exento</th><th>Nombre</th><th>RFC</th></tr>
        </thead>
        <tbody>
          <tr v-for="row in regimen" :key="row.cvecont">
            <td>{{ row.encabeza }}</td>
            <td>{{ row.porcentaje }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.exento }}</td>
            <td>{{ row.ncompleto }}</td>
            <td>{{ row.rfc }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="valores">
      <h2>Valores</h2>
      <table class="table table-bordered">
        <thead>
          <tr><th>Año</th><th>Bim</th><th>Tasa</th><th>Valor Fiscal</th></tr>
        </thead>
        <tbody>
          <tr v-for="row in valores" :key="row.axoefec + '-' + row.bimefec">
            <td>{{ row.axoefec }}</td>
            <td>{{ row.bimefec }}</td>
            <td>{{ row.tasa }}</td>
            <td>{{ row.valfiscal }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="ubicacion">
      <h2>Ubicación</h2>
      <table class="table table-bordered">
        <tr><th>Calle</th><td>{{ ubicacion.calle }}</td></tr>
        <tr><th>No. Exterior</th><td>{{ ubicacion.noexterior }}</td></tr>
        <tr><th>Interior</th><td>{{ ubicacion.interior }}</td></tr>
        <tr><th>Colonia</th><td>{{ ubicacion.colonia }}</td></tr>
        <tr><th>Vigencia</th><td>{{ ubicacion.vigencia }}</td></tr>
      </table>
    </div>
    <div v-if="graficoUrl">
      <h2>Ubicación Cartográfica</h2>
      <iframe :src="graficoUrl" width="100%" height="500" frameborder="0"></iframe>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaPredialPage',
  data() {
    return {
      form: {
        recaud: '',
        urbrus: '',
        cuenta: ''
      },
      cuenta: null,
      saldos: null,
      recibos: null,
      requerimientos: null,
      regimen: null,
      valores: null,
      ubicacion: null,
      graficoUrl: null
    };
  },
  methods: {
    async buscarCuenta() {
      // Buscar cuenta
      const res = await this.api('getCuenta', {
        recaud: this.form.recaud,
        urbrus: this.form.urbrus,
        cuenta: this.form.cuenta
      });
      if (res.success && res.data && res.data.length > 0) {
        this.cuenta = res.data[0];
        await this.cargarDatosCuenta(this.cuenta.cvecuenta, this.cuenta.cvecatnva);
      } else {
        this.cuenta = null;
        alert('Cuenta no encontrada');
      }
    },
    async cargarDatosCuenta(cvecuenta, clave_cat) {
      // Saldos
      const saldosRes = await this.api('getSaldos', { cvecuenta });
      this.saldos = saldosRes.success ? saldosRes.data : null;
      // Recibos
      const recibosRes = await this.api('getRecibos', { cvecuenta });
      this.recibos = recibosRes.success ? recibosRes.data : null;
      // Requerimientos
      const reqRes = await this.api('getRequerimientos', { cvecuenta });
      this.requerimientos = reqRes.success ? reqRes.data : null;
      // Regimen
      const regRes = await this.api('getRegimenPropiedad', { cvecuenta });
      this.regimen = regRes.success ? regRes.data : null;
      // Valores
      const valRes = await this.api('getValores', { cvecuenta });
      this.valores = valRes.success ? valRes.data : null;
      // Ubicacion
      const ubiRes = await this.api('getUbicacion', { cvecuenta });
      this.ubicacion = ubiRes.success && ubiRes.data.length > 0 ? ubiRes.data[0] : null;
      // Limpiar gráfico
      this.graficoUrl = null;
    },
    async verGrafico() {
      if (!this.cuenta || !this.cuenta.cvecatnva) return;
      const res = await this.api('getGraficoUrl', { clave_cat: this.cuenta.cvecatnva });
      if (res.success && res.data && res.data.url) {
        this.graficoUrl = res.data.url;
      }
    },
    async api(action, params) {
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action, params })
        });
        return await resp.json();
      } catch (e) {
        alert('Error de comunicación con el servidor');
        return { success: false };
      }
    }
  }
};
</script>

<style scoped>
.consulta-predial-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  color: #888;
}
.form-row {
  display: flex;
  gap: 1rem;
  align-items: center;
  margin-bottom: 1.5rem;
}
.table {
  width: 100%;
  margin-bottom: 2rem;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ddd;
  padding: 0.5rem;
}
.table th {
  background: #f8f8f8;
}
</style>
