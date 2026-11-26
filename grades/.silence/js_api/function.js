    // {{description}}
    {{name}}: async function ({{args}}) {
        let response = await axios.{{method}}(`${BASE_URL}{{route}}`{{body}}, requestOptions);
        return response.data;
    },
