<template>
  <div class="cargadatos-page">
    <h1>Consulta de Datos Catastrales</h1>
    <form @submit.prevent="onBuscar">
      <div class="form-row">
        <label for="cvecatnva">Clave Catastral:</label>
        <input v-model="form.cvecatnva" id="cvecatnva" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="data">
      <section class="section">
        <h2>Ubicación y Tenencia</h2>
        <div class="grid">
          <div><strong>Calle:</strong> {{ data.calle }}</div>
          <div><strong>No.:</strong> {{ data.noexterior }}</div>
          <div><strong>Int.:</strong> {{ data.interior }}</div>
          <div><strong>Colonia:</strong> {{ data.colonia }}</div>
          <div><strong>Propietario:</strong> {{ data.nombre_completo }}</div>
          <div><strong>RFC:</strong> {{ data.rfc }}</div>
          <div><strong>Domicilio:</strong> {{ data.domicilio }}</div>
          <div><strong>Población:</strong> {{ data.poblacion }}</div>
          <div><strong>C.P.:</strong> {{ data.codpos }}</div>
        </div>
      </section>
      <section class="section">
        <h2>Avalúos</h2>
        <table class="table">
          <thead>
            <tr>
              <th>Sup. Terreno</th>
              <th>Sup. Const.</th>
              <th>Valor Terreno</th>
              <th>Valor Const.</th>
              <th>Valor Fiscal</th>
              <th>Fecha Avalúo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="ava in avaluos" :key="ava.cveavaluo">
              <td>{{ ava.supterr }}</td>
              <td>{{ ava.supconst }}</td>
              <td>{{ ava.valorterr }}</td>
              <td>{{ ava.valorconst }}</td>
              <td>{{ ava.valfiscal }}</td>
              <td>{{ ava.feccap }}</td>
            </tr>
          </tbody>
        </table>
      </section>
      <section class="section">
        <h2>Construcciones</h2>
        <table class="table">
          <thead>
            <tr>
              <th>No. Bloque</th>
              <th>Matriz</th>
              <th>Clasificación</th>
              <th>Área (m2)</th>
              <th>Importe</th>
              <th>No. Pisos</th>
              <th>Estructura</th>
              <th>Factor Ajuste</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="con in construcciones" :key="con.cvebloque">
              <td>{{ con.cvebloque }}</td>
              <td>{{ con.cveclasif }}</td>
              <td>{{ con.descripcion }}</td>
              <td>{{ con.areaconst }}</td>
              <td>{{ con.importe }}</td>
              <td>{{ con.numpisos }}</td>
              <td>{{ con.estructura }}</td>
              <td>{{ con.factorajus }}</td>
            </tr>
          </tbody>
        </table>
      </section>
      <section class="section">
        <h2>Área Cartográfica</h2>
        <div v-if="areaCarto">
          <strong>Sup. Const. Carto:</strong> {{ areaCarto.supconst }} m²
        </div>
        <div v-else>
          No disponible
        </div>
      </section>
      <section class="section">
        <h2>Observaciones Avalúo</h2>
        <div>{{ data.observacion }}</div>
      </section>
      <section class="section">
        <h2>Usos de Suelo</h2>
        <table class="table">
          <thead>
            <tr>
              <th>Uso</th>
              <th>Descripción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="uso in data.usos || []" :key="uso.id">
              <td>{{ uso.uso }}</td>
              <td>{{ uso.descripcion }}</td>
            </tr>
          </tbody>
        </table>
      </section>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CargadatosPage',
  data() {
    return {
      form: {
        cvecatnva: ''
      },
      data: null,
      avaluos: [],
      construcciones: [],
      areaCarto: null,
      loading: false,
      error: ''
    }
  },
  methods: {
    async onBuscar() {
      this.loading = true;
      this.error = '';
      this.data = null;
      this.avaluos = [];
      this.construcciones = [];
      this.areaCarto = null;
      try {
        // 1. Datos principales
        const res = await this.$axios.post('/api/execute', {
          action: 'getCargadatos',
          params: { cvecatnva: this.form.cvecatnva }
        });
        if (!res.data.success) throw new Error(res.data.message);
        this.data = res.data.data;
        // 2. Avalúos
        const resAva = await this.$axios.post('/api/execute', {
          action: 'getAvaluos',
          params: { cvecatnva: this.form.cvecatnva, subpredio: 0 }
        });
        this.avaluos = resAva.data.data || [];
        // 3. Construcciones (del primer avalúo)
        if (this.avaluos.length > 0) {
          const resCons = await this.$axios.post('/api/execute', {
            action: 'getConstrucciones',
            params: { cveavaluo: this.avaluos[0].cveavaluo }
          });
          this.construcciones = resCons.data.data || [];
        }
        // 4. Área cartográfica
        const resCarto = await this.$axios.post('/api/execute', {
          action: 'getAreaCarto',
          params: { cvecatnva: this.form.cvecatnva }
        });
        this.areaCarto = resCarto.data.data;
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.cargadatos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.section {
  margin-bottom: 2rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.error {
  color: red;
}
</style>
