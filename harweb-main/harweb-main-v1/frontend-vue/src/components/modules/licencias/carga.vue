<template>
  <div class="carga-formulario">
    <h1>Consulta Cartografía Predial</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Cartografía Predial</li>
      </ol>
    </nav>
    <form @submit.prevent="buscarPredio">
      <div class="form-group">
        <label>Clave Catastral</label>
        <input v-model="form.cvecatnva" class="form-control" maxlength="8" required />
      </div>
      <div class="form-group">
        <label>Subpredio</label>
        <input v-model.number="form.subpredio" class="form-control" type="number" min="0" />
      </div>
      <button class="btn btn-primary" type="submit">Buscar</button>
    </form>
    <div v-if="predio">
      <h3>Datos del Predio</h3>
      <table class="table table-bordered">
        <tr><th>Clave Catastral</th><td>{{ predio.cvecatnva }}</td></tr>
        <tr><th>Cuenta</th><td>{{ predio.cuenta }}</td></tr>
        <tr><th>Recaudadora</th><td>{{ predio.recaud }}</td></tr>
        <tr><th>Urb/Rus</th><td>{{ predio.urbrus }}</td></tr>
        <tr><th>Propietario</th><td>{{ predio.propietario }}</td></tr>
        <tr><th>Ubicación</th><td>{{ predio.ubicacion }}</td></tr>
        <tr><th>Colonia</th><td>{{ predio.colonia }}</td></tr>
        <tr><th>No. Exterior</th><td>{{ predio.noexterior }}</td></tr>
        <tr><th>No. Interior</th><td>{{ predio.interior }}</td></tr>
        <tr><th>Superficie Terreno</th><td>{{ predio.supterr }}</td></tr>
        <tr><th>Superficie Construcción</th><td>{{ predio.supconst }}</td></tr>
        <tr><th>Valor Terreno</th><td>{{ predio.valorterr | currency }}</td></tr>
        <tr><th>Valor Construcción</th><td>{{ predio.valorconst | currency }}</td></tr>
        <tr><th>Valor Fiscal</th><td>{{ predio.valfiscal | currency }}</td></tr>
      </table>
      <div class="mt-3">
        <button class="btn btn-secondary" @click="verCartografia">Ver Cartografía</button>
        <button class="btn btn-info" @click="verNumerosOficiales">Números Oficiales</button>
        <button class="btn btn-success" @click="verCondominio">Condominio</button>
      </div>
    </div>
    <div v-if="cartografia">
      <h3>Cartografía Predial</h3>
      <pre>{{ cartografia }}</pre>
    </div>
    <div v-if="numerosOficiales">
      <h3>Números Oficiales</h3>
      <pre>{{ numerosOficiales }}</pre>
    </div>
    <div v-if="condominio">
      <h3>Condominio</h3>
      <pre>{{ condominio }}</pre>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'CargaFormulario',
  data() {
    return {
      form: {
        cvecatnva: '',
        subpredio: 0
      },
      predio: null,
      cartografia: null,
      numerosOficiales: null,
      condominio: null,
      error: null
    };
  },
  methods: {
    async buscarPredio() {
      this.error = null;
      this.predio = null;
      this.cartografia = null;
      this.numerosOficiales = null;
      this.condominio = null;
      try {
        const eRequest = {
          action: 'getPredioByClaveCatastral',
          params: {
            cvecatnva: this.form.cvecatnva,
            subpredio: this.form.subpredio
          }
        };
        const res = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        });
        const data = await res.json();
        if (data.eResponse && !data.eResponse.error) {
          this.predio = data.eResponse[0];
        } else {
          this.error = data.eResponse.error || 'No se encontró el predio.';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async verCartografia() {
      if (!this.predio) return;
      this.cartografia = null;
      try {
        const eRequest = {
          action: 'getCartografia',
          params: { cvecatnva: this.predio.cvecatnva }
        };
        const res = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        });
        const data = await res.json();
        this.cartografia = data.eResponse;
      } catch (e) {
        this.error = e.message;
      }
    },
    async verNumerosOficiales() {
      if (!this.predio) return;
      this.numerosOficiales = null;
      try {
        const eRequest = {
          action: 'getNumerosOficiales',
          params: { cvemanz: this.predio.cvecatnva.substr(0,8) }
        };
        const res = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        });
        const data = await res.json();
        this.numerosOficiales = data.eResponse;
      } catch (e) {
        this.error = e.message;
      }
    },
    async verCondominio() {
      if (!this.predio) return;
      this.condominio = null;
      try {
        const eRequest = {
          action: 'getCondominio',
          params: { cvecatnva: this.predio.cvecatnva }
        };
        const res = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        });
        const data = await res.json();
        this.condominio = data.eResponse;
      } catch (e) {
        this.error = e.message;
      }
    }
  },
  filters: {
    currency(val) {
      if (!val) return '$0.00';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.carga-formulario {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
