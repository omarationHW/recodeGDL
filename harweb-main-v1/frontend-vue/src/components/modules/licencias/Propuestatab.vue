<template>
  <div class="propuestatab-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Consulta Histórica de Cuenta</li>
      </ol>
    </nav>
    <h1>Consulta Histórica de Cuenta</h1>
    <form @submit.prevent="buscarCuenta">
      <div class="form-group row">
        <label class="col-sm-2 col-form-label">Cuenta Catastral</label>
        <div class="col-sm-4">
          <input v-model="cvecuenta" class="form-control" required placeholder="Ingrese cuenta catastral" />
        </div>
        <div class="col-sm-2">
          <button class="btn btn-primary" type="submit">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="cuenta">
      <h2>Datos de Cuenta</h2>
      <table class="table table-bordered">
        <tr><th>Cuenta</th><td>{{ cuenta.cvecuenta }}</td></tr>
        <tr><th>Clave Catastral</th><td>{{ cuenta.cvecatnva }}</td></tr>
        <tr><th>Subpredio</th><td>{{ cuenta.subpredio }}</td></tr>
        <tr><th>Movimiento</th><td>{{ cuenta.cmovto }}</td></tr>
        <tr><th>Observaciones</th><td>{{ cuenta.observacion }}</td></tr>
        <tr><th>Tasa</th><td>{{ cuenta.tasa }}</td></tr>
        <tr><th>Indiviso</th><td>{{ cuenta.indiviso }}</td></tr>
      </table>
      <h3>Ubicación</h3>
      <table class="table table-bordered">
        <tr><th>Calle</th><td>{{ cuenta.calle }}</td></tr>
        <tr><th>No. Exterior</th><td>{{ cuenta.noexterior }}</td></tr>
        <tr><th>Interior</th><td>{{ cuenta.interior }}</td></tr>
        <tr><th>Colonia</th><td>{{ cuenta.colonia }}</td></tr>
        <tr><th>Vigencia</th><td>{{ cuenta.vigencia }}</td></tr>
        <tr><th>Información Adicional</th><td>{{ cuenta.obsinter }}</td></tr>
      </table>
      <h3>Régimen de Propiedad</h3>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Encabeza</th><th>%</th><th>Calidad de</th><th>Exento</th><th>Nombre</th><th>RFC</th><th>Domicilio</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="reg in regimen" :key="reg.cvereg">
            <td>{{ reg.encabeza }}</td>
            <td>{{ reg.porcentaje }}</td>
            <td>{{ reg.descripcion }}</td>
            <td>{{ reg.exento }}</td>
            <td>{{ reg.ncompleto }}</td>
            <td>{{ reg.rfc }}</td>
            <td>{{ reg.calle }} {{ reg.noexterior }} {{ reg.interior }}</td>
          </tr>
        </tbody>
      </table>
      <h3>Valores</h3>
      <table class="table table-bordered">
        <tr><th>Fecha Otorgamiento</th><td>{{ cuenta.fechaotorg }}</td></tr>
        <tr><th>Pago Transm. Patrimonial</th><td>{{ cuenta.importe }}</td></tr>
        <tr><th>Valor de Transmisión</th><td>{{ cuenta.valortransm }}</td></tr>
        <tr><th>Sup. S/Título</th><td>{{ cuenta.areatitulo }}</td></tr>
        <tr><th>Notario</th><td>{{ cuenta.notario }}</td></tr>
        <tr><th>No. Escrituras</th><td>{{ cuenta.noescrituras }}</td></tr>
      </table>
      <h3>Diferencias</h3>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Bim Ini</th><th>Año Ini</th><th>Bim Fin</th><th>Año Fin</th><th>Tasa Ant.</th><th>ST Ant.</th><th>Valor Ant.</th><th>Tasa Nva.</th><th>ST Nva.</th><th>Valor Nvo.</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="dif in diferencias" :key="dif.id">
            <td>{{ dif.bimini }}</td>
            <td>{{ dif.axoini }}</td>
            <td>{{ dif.bimfin }}</td>
            <td>{{ dif.axofin }}</td>
            <td>{{ dif.tasaant }}</td>
            <td>{{ dif.stasaant }}</td>
            <td>{{ dif.valfisant }}</td>
            <td>{{ dif.tasa }}</td>
            <td>{{ dif.axosobretasa }}</td>
            <td>{{ dif.valfiscal }}</td>
          </tr>
        </tbody>
      </table>
      <h3>Observaciones AS-400</h3>
      <table class="table table-bordered">
        <thead>
          <tr><th>Comprobante</th><th>Observaciones</th></tr>
        </thead>
        <tbody>
          <tr v-for="obs in obs400" :key="obs.acomp">
            <td>{{ obs.acomp }}</td>
            <td>{{ obs.observa }}</td>
          </tr>
        </tbody>
      </table>
      <h3>Condómino</h3>
      <table class="table table-bordered">
        <tr><th>Nombre</th><td>{{ condominio.nombre }}</td></tr>
        <tr><th>Tipo</th><td>{{ condominio.tipocond }}</td></tr>
        <tr><th>No. Predios</th><td>{{ condominio.numpred }}</td></tr>
        <tr><th>Escritura</th><td>{{ condominio.escritura }}</td></tr>
        <tr><th>Fecha Escritura</th><td>{{ condominio.fecescrit }}</td></tr>
        <tr><th>Área Común</th><td>{{ condominio.areacomun }}</td></tr>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PropuestatabPage',
  data() {
    return {
      cvecuenta: '',
      cuenta: null,
      regimen: [],
      diferencias: [],
      obs400: [],
      condominio: {},
      loading: false,
      error: '',
    };
  },
  methods: {
    async buscarCuenta() {
      this.loading = true;
      this.error = '';
      try {
        // 1. Datos de cuenta principal
        let eRequest = { action: 'list', params: { cvecuenta: this.cvecuenta } };
        let response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        let res = await response.json();
        if (res.eResponse && res.eResponse.length > 0) {
          this.cuenta = res.eResponse[0];
        } else {
          this.cuenta = null;
          this.error = 'Cuenta no encontrada';
          this.loading = false;
          return;
        }
        // 2. Régimen de propiedad
        eRequest = { action: 'regimen', params: { cvecuenta: this.cvecuenta } };
        response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        res = await response.json();
        this.regimen = res.eResponse || [];
        // 3. Diferencias
        eRequest = { action: 'diferencias', params: { cvecuenta: this.cvecuenta } };
        response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        res = await response.json();
        this.diferencias = res.eResponse || [];
        // 4. Observaciones AS-400
        eRequest = { action: 'obs400', params: {
          recaud: this.cuenta.recaud,
          urbrus: this.cuenta.urbrus,
          cuenta: this.cuenta.cuenta
        } };
        response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        res = await response.json();
        this.obs400 = res.eResponse || [];
        // 5. Condominio
        eRequest = { action: 'condominio', params: { cvecatnva: this.cuenta.cvecatnva } };
        response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        res = await response.json();
        this.condominio = res.eResponse && res.eResponse[0] ? res.eResponse[0] : {};
      } catch (e) {
        this.error = e.response && e.response.data && e.response.data.eResponse && e.response.data.eResponse.error ? e.response.data.eResponse.error : e.message;
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.propuestatab-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
}
</style>
